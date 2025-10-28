#ifndef OO_STRING_H
#define OO_STRING_H

#include <stdarg.h>   // va_list, va_start, va_end
#include <stdio.h>    // vsnprintf
#include <stdlib.h>   // malloc, size_t, NULL
#include "oo-alloc.h"
#include "oo-runtime.h"

struct __string_data {
    size_t length;
    char buffer[];
};
typedef struct string {
    struct __oo_rc_header header;
    struct __string_data data;
} string;
static __oo_struct_type __string_info = {.size = sizeof(string)};

static inline string* string_format(const char* const format, ...) {
    va_list args;
    va_start(args, format);

    // Determine the required buffer size
    int length = vsnprintf(NULL, 0, format, args) + 1;
    string* s = (string*) __oo_alloc(__string_info.size + length);
    s->header.is_a = &__string_info;
    s->header.semantics = __oo_ISOLATED;
    atomic_init(&s->header.refs, 1);

    // Format the string into the buffer
    vsnprintf(s->data.buffer, length, format, args);
    s->data.length = length - 1; // Exclude the null terminator
    va_end(args);
    return s;
}

/// @brief Print a string value to stdout
/// @param s the string value
static inline void print(string* const s) {
    printf("%s\n", s->data.buffer);
}

#endif /*.OO_STRING_H */
