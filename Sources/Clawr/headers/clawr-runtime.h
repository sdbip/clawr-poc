#ifndef CLAWR_RUNTIME_H
#define CLAWR_RUNTIME_H

#include <stdlib.h>      // malloc, size_t, NULL
#include <stdint.h>      // uintptr_t, UINTPTR_MAX
#include <stdatomic.h>   // atomic_uintptr_t, atomic_init, _Atomic
#include <string.h>      // memcpy
#include <unistd.h>      // usleep
#include <stdio.h>       // stderr, fprintf

/*
    Implementation of copy-on-write memory handling.

    Thread safety is guaranteed using std::atomic.
    NOTE: The current strategy has not been tested thouroughly.
    - How *do* you test low-level concurrency?
    - How do you test that memory is actually freed?

    The std:atomic (sometimes ‘C++0x’) functions guarantee read/write atomicity per operation.
    They enable **optimistic concurrency**. Races will still happen, but values are not updated
    if they have been changed by another thread between separate load and store operations.

    I haven't found good documentation on this, but it matches my own implementation of adding
    events to entities in Segerfeldt.EventStore (C#).
 */

/// @brief Flag to indicate that a memory block is currently being copied. It must not be modified.
static const uintptr_t __clawr_COPYING_FLAG   = (uintptr_t)1 << (sizeof(uintptr_t) * 8 - 1);
/// @brief Flag to indicate variable semantics for an entity’s allocated memory block.
static const uintptr_t __clawr_ISOLATION_FLAG = (uintptr_t)1 << (sizeof(uintptr_t) * 8 - 2);
/// @brief Bitmask for the reference counter
static const uintptr_t __clawr_REFC_BITMASK   = ~(__clawr_COPYING_FLAG | __clawr_ISOLATION_FLAG);

/// @brief Reference Semantics (`ref` variable) - One entity, multiple variables
static const uintptr_t __clawr_REFERENCE      = 0;
/// @brief Isolation Semantics (`let`, `mut` variable) - Variables modified independently
static const uintptr_t __clawr_ISOLATED       = __clawr_ISOLATION_FLAG;

/// @brief Descriptor for a trait. The address of a descriptor is a unique identifier
/// for a trait at compile-time; user code should define one static descriptor per trait.
typedef struct __clawr_trait_descriptor {
    const char* name;
} __clawr_trait_descriptor;

/// @brief Flag to indicate structural semantics for a type.
static const uintptr_t __clawr_INHERITANCE_FLAG = (uintptr_t)1 << (sizeof(uintptr_t) * 8 - 1);

/// @brief Information about an entity’s type (`data` or `object`)
/// This should include:
/// - inheritance and conformance information
/// - method lookup table if `object` type
/// - field layout info if `data` type
typedef struct __clawr_data_type {

    /// @brief The size of the entity payload for this type, and its semantics
    uintptr_t size;

    /// @brief Parallel arrays describing implemented traits for this type.
    /// `trait_descs[i]` is a pointer to the compile-time `__clawr_trait_descriptor` for a trait
    /// and `trait_vtables[i]` is the vtable implementation for that trait for this type.
    const __clawr_trait_descriptor** trait_descs;
    void** trait_vtables;
    size_t trait_count;

} __clawr_data_type;

/// @brief Information about an entity’s type (`data` or `object`)
/// This should include:
/// - inheritance and conformance information
/// - method lookup table if `object` type
/// - field layout info if `data` type
typedef struct __clawr_object_type {

    /// @brief The size of the entity payload for this type
    size_t size;

    /// @brief Parallel arrays describing implemented traits for this type.
    /// `trait_descs[i]` is a pointer to the compile-time `__clawr_trait_descriptor` for a trait
    /// and `trait_vtables[i]` is the vtable implementation for that trait for this type.
    const __clawr_trait_descriptor** trait_descs;
    void** trait_vtables;
    size_t trait_count;

    // ----- Replicate __clawr_data_type above this line ------ //

    /// @brief A vtable is used to look up functions (methods) that can be overridden
    /// if a method is non-overridable, it should be referenced directly instead.
    void* vtable;

    /// @brief The `object` supertype of this `object` type.
    /// Must be `NULL` for `data` types
    struct __clawr_object_type* super;

} __clawr_object_type;

typedef union __clawr_type_info {
    __clawr_data_type* data;
    __clawr_object_type* object;
} __clawr_type_info;

/// A header that is prefixed on all programmer types
typedef struct __clawr_rc_header {
    /// @brief Reference counter and semantics flags (COPYING | ISOLATED | refcounter)
    atomic_uintptr_t refs;
    /// @brief Pointer to type data
    __clawr_type_info is_a;
} __clawr_rc_header;

// -------- Implementation -------- ||

/// @brief Lookup a trait vtable for an entity at runtime
/// @param self pointer to the entity (must start with __clawr_rc_header)
/// @param trait pointer to the trait descriptor to look up
/// @return the vtable pointer for the trait if implemented, otherwise NULL
static inline void* __clawr_trait_vtable(__clawr_rc_header* header, const __clawr_trait_descriptor* trait) {
    if (!header || !trait) return NULL;
    __clawr_type_info typeInfo = header->is_a;
    if (!typeInfo.data || !typeInfo.data->trait_descs || !typeInfo.data->trait_vtables) return NULL;

    for (size_t i = 0; i < typeInfo.data->trait_count; i++) {
        if (typeInfo.data->trait_descs[i] == trait) {
            return typeInfo.data->trait_vtables[i];
        }
    }
    return NULL;
}

static inline void* __clawr_alloc(size_t size) {
    void* const memory = malloc(size);
    if (memory == NULL) {
        // TODO: Allow user to manage memory?
        fprintf(stderr, "Out of memory!");
        exit(EXIT_FAILURE);
    }
    return memory;
}

/// @brief Allocate reference-counted entity in memory
/// @param semantics the semantics, copy or reference, to apply when assigning and modifying the entity
/// @param typeInfo pointer to an object that represents the entity’s type
static inline void* allocRC(__clawr_type_info const typeInfo, uintptr_t const semantics) {
    __clawr_rc_header* const header = (__clawr_rc_header*)__clawr_alloc(typeInfo.data->size);
    header->is_a = typeInfo;
    atomic_init(&header->refs, semantics | 1);
    return header;
}

/// @brief Increment a reference counter
/// @param header the header of the entity to retain
static inline __clawr_rc_header* retainRC(__clawr_rc_header* const header) {
    if (header) atomic_fetch_add_explicit(&header->refs, 1, memory_order_relaxed);
    return header;
}

/// @brief Decrement the reference counter of an entity
/// If the reference counter becomes zero, the entity is descoped
/// @param header the header of the entity to release
/// @returns `NULL` so that the variable can be assigned to the function call.
static inline void* releaseRC(__clawr_rc_header* const header) {
    if (header && (atomic_fetch_sub_explicit(&header->refs, 1, memory_order_acq_rel) & __clawr_REFC_BITMASK) == 1) {
        free(header);
    }
    return NULL;
}

/// @brief Copy-on-write action. Call before modifications.
/// Maintains variable isolation by creating a copy of the entity
/// — if it has `__clawr_ISOLATED` semantics and there are multipe referents.
/// Always replace the variable with the returned value.
/// @param header the entity to modify
/// @return the entity itself or a copy if CoW was triggered
/// @example
/// @code
/// ```
/// MyType* x = allocRC(__MyType_info, __clawr_ISOLATED);
/// // Initialize x and use it
/// MyType* y = retainRC(x);
/// x = isolateRC(x);
/// // Make isolated changes to x
/// ```
/// @endcode
static inline void* isolateRC(__clawr_rc_header* const header) {
    if (!header) return NULL;
    // The ISOLATION flag never changes, so data races are irrelevant
    // Access directly instead of through atomic_load()
    if ((header->refs & __clawr_ISOLATION_FLAG) == __clawr_REFERENCE) {
        // No copy for reference semantics
        return header;
    }

    // Flag for copying.
    // refs |= __clawr_COPYING_FLAG
    uintptr_t refs = atomic_fetch_or_explicit(&header->refs, __clawr_COPYING_FLAG, memory_order_acquire);
    if ((refs & __clawr_REFC_BITMASK) == 1) {
        // No copy necessary for uniquely referenced entity. Unset the copying flag immediately.
        // refs &= ~__clawr_COPYING_FLAG
        atomic_fetch_and_explicit(&header->refs, ~__clawr_COPYING_FLAG, memory_order_acquire);
        return header;
    } else if (refs & __clawr_COPYING_FLAG) {
        usleep(100);
        return isolateRC(header);
    }

    // Copy payload for copy semantics with shared ownership
    __clawr_type_info const typeInfo = header->is_a;
    __clawr_rc_header* const newEntity = (__clawr_rc_header*)__clawr_alloc(typeInfo.data->size);
    memcpy(newEntity, header, typeInfo.data->size);

    // Preserve semantics flag on the new entity; start with unique refcount 1
    atomic_init(&newEntity->refs, (refs & __clawr_ISOLATION_FLAG) | 1);

    // Finished copying. Drop our strong ref to the original entity and unset the flag.
    atomic_fetch_and_explicit(&header->refs, ~__clawr_COPYING_FLAG, memory_order_acquire);
    releaseRC(header);

    return newEntity;
}

#endif /* CLAWR_RUNTIME_H */
