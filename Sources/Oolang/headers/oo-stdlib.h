#ifndef OO_STDLIB_H
#define OO_STDLIB_H

#include <inttypes.h> // PRIx64, uint64_t, int64_t
#include <math.h>     // fabs
#include <stdio.h>    // printf
#include "oo-string.h"

typedef struct box
{
    __oo_rc_header header;
    size_t boxed;
} box;

box* __oo_make_box(size_t value, __oo_struct_type* type) {
    box* b = oo_alloc(__oo_ISOLATED, type);
    b->boxed = value;
    return b;
}

typedef int64_t integer;

// model integer: HasStringRepresentation {
//     func toString() { ... }
// }
static inline string* const integer_toString(integer const self) {
    return string_format("%" PRId64, self);
}
static inline string* integer_box_toString(void* self) {
    return integer_toString(((box*)self)->boxed);
}
static const HasStringRepresentation_vtable integer_HasStringRepresentation_vtable = {
    .toString = integer_box_toString
};

static __oo_struct_type __integer_box_info = {
    .size = sizeof(box),
    .trait_descs = (__oo_trait_descriptor*[]) { &HasStringRepresentation_trait },
    .trait_vtables = (void*[]) { &integer_HasStringRepresentation_vtable },
    .trait_count = 1
};

typedef double real;

// model real: HasStringRepresentation {
//     func toString() { ... }
// }
static inline string* const real_toString(real const self) {
    if (fabs(self) >= 1e6 || fabs(self) < 1e-3) {
        return string_format("%#.1e", self);  // Scientific notation with decimal point
    } else {
        return string_format("%.1f", self);   // Regular decimal notation
    }
}
static inline string* real_box_toString(void* self) {
    return real_toString(((box*)self)->boxed);
}
static const HasStringRepresentation_vtable real_HasStringRepresentation_vtable = {
    .toString = real_box_toString
};

static __oo_struct_type __real_box_info = {
    .size = sizeof(box),
    .trait_descs = (__oo_trait_descriptor*[]) { &HasStringRepresentation_trait },
    .trait_vtables = (void*[]) { &real_HasStringRepresentation_vtable },
    .trait_count = 1
};

typedef uint64_t bitfield;

// model bitfield: HasStringRepresentation {
//     func toString() { ... }
// }
static inline string* const bitfield_toString(bitfield const self) {
    return string_format("%018#" PRIx64, self);
}
static inline string* bitfield_box_toString(void* self) {
    return bitfield_toString(((box*)self)->boxed);
}
static const HasStringRepresentation_vtable bitfield_HasStringRepresentation_vtable = {
    .toString = bitfield_box_toString
};

static __oo_struct_type __bitfield_box_info = {
    .size = sizeof(box),
    .trait_descs = (__oo_trait_descriptor*[]) { &HasStringRepresentation_trait },
    .trait_vtables = (void*[]) { &bitfield_HasStringRepresentation_vtable },
    .trait_count = 1
};

#endif /* OO_STDLIB_H */
