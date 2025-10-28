#ifndef OO_STRING_H
#define OO_STRING_H

#include <stdarg.h>   // va_list, va_start, va_end
#include <stdio.h>    // vsnprintf
#include <stdlib.h>   // malloc, size_t, NULL
#include "oo-alloc.h"

typedef struct string {
    int length;
    char buffer[];
} string;

static inline string* string_format(const char* const format, ...) {
    va_list args;
    va_start(args, format);

    // Determine the required buffer size
    int length = vsnprintf(NULL, 0, format, args) + 1;
    string* s = (string*)__oo_alloc(sizeof(string) + length);

    // Format the string into the buffer
    vsnprintf(s->buffer, length, format, args);
    s->length = length - 1; // Exclude the null terminator
    va_end(args);
    return s;
}

/// @brief Print a string value to stdout
/// @param s the string value
void print(string* const s) {
    printf("%s\n", s->buffer);
}

#endif /*.OO_STRING_H */
