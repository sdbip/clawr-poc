#ifndef OO_STRING_H
#define OO_STRING_H

#include <stdarg.h>   // va_list, va_start, va_end
#include <stdio.h>    // vsnprintf
#include <stdlib.h>   // malloc, size_t, NULL
#include "oo-alloc.h"
#include "oo-runtime.h"

// data string {
//     length: integer
// }
struct __string_data {
    size_t length;
    char buffer[];
};
typedef struct string {
    struct __oo_rc_header header;
    struct __string_data data;
} string;

// trait HasStringRepresentation {
//     func toString() -> string
// }
typedef struct HasStringRepresentation_vtable {
    string* (*toString)(void* self);
} HasStringRepresentation_vtable;
static const __oo_trait_descriptor HasStringRepresentation_trait = { .name = "HasStringRepresentation" };

static inline string* string_toString(void* self) {
    return oo_retain(self);
}
static const HasStringRepresentation_vtable string_HasStringRepresentation_vtable = {
    .toString = string_toString
};
static __oo_data_type __string_data_type = {
    .size = sizeof(string),
    .trait_descs = (__oo_trait_descriptor*[]) { &HasStringRepresentation_trait },
    .trait_vtables = (void*[]) { &string_HasStringRepresentation_vtable },
    .trait_count = 1,
};
static __oo_type_info __string_info = { .data = &__string_data_type };

static inline string* string_format(const char* const format, ...) {
    va_list args;
    va_start(args, format);

    // Determine the required buffer size
    int length = vsnprintf(NULL, 0, format, args) + 1;
    string* s = (string*) __oo_alloc(__string_data_type.size + length);
    s->header.is_a = __string_info;
    atomic_init(&s->header.refs, __oo_ISOLATED | 1);

    // Format the string into the buffer
    vsnprintf(s->data.buffer, length, format, args);
    s->data.length = length - 1; // Exclude the null terminator
    va_end(args);
    return s;
}

/// @brief Print a string value to stdout
/// @param s the string value
static inline void print(__oo_rc_header* const i) {
    HasStringRepresentation_vtable* vtable =
        (HasStringRepresentation_vtable*) __oo_trait_vtable(i, &HasStringRepresentation_trait);
    if (!vtable) {
        printf("vtable not found!!");
        exit(EXIT_FAILURE);
    }

    string* s = vtable->toString(i);
    printf("%s\n", s->data.buffer);
    s = oo_release(s);
}

#endif /*.OO_STRING_H */
