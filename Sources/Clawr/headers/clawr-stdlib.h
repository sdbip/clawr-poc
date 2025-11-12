#ifndef CLAWR_STDLIB_H
#define CLAWR_STDLIB_H

#include <inttypes.h> // PRIx64, uint64_t, int64_t
#include <math.h>     // fabs
#include <stdio.h>    // printf
#include "clawr-string.h"

typedef struct box
{
    __clawr_rc_header header;
    uintptr_t boxed;
} box;

box* __clawr_make_box(uintptr_t value, __clawr_type_info type) {
    box* b = allocRC(type, __clawr_ISOLATED);
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

static __clawr_data_type __integer_box_data_type = {
    .size = sizeof(box),
    .trait_descs = (__clawr_trait_descriptor*[]) { &HasStringRepresentation_trait },
    .trait_vtables = (void*[]) { &integer_HasStringRepresentation_vtable },
    .trait_count = 1
};
static const __clawr_type_info __integer_box_info = { .data = &__integer_box_data_type };

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

static __clawr_data_type __real_box_data_type = {
    .size = sizeof(box),
    .trait_descs = (__clawr_trait_descriptor*[]) { &HasStringRepresentation_trait },
    .trait_vtables = (void*[]) { &real_HasStringRepresentation_vtable },
    .trait_count = 1
};
static const __clawr_type_info __real_box_info = { .data = &__real_box_data_type };

typedef uint64_t bitfield;

// model bitfield: HasStringRepresentation {
//     func toString() { ... }
// }
static inline string* const bitfield_toString(bitfield const self) {
    // Hex representation without underscores
    char buffer[22];
    sprintf(buffer, "%018#" PRIx64, self);

    // Move three groups of four digits leaving one space between
    memmove(buffer + 17, buffer + 14, 4);
    memmove(buffer + 12, buffer + 10, 4);
    memmove(buffer + 7, buffer + 6, 4);
    buffer[6] = buffer[11] = buffer[16] = '_';
    buffer[21] = 0;

    return string_format(buffer);
}
static inline string* bitfield_box_toString(void* self) {
    return bitfield_toString(((box*)self)->boxed);
}
static const HasStringRepresentation_vtable bitfield_HasStringRepresentation_vtable = {
    .toString = bitfield_box_toString
};

static const __clawr_data_type __bitfield_box_data_type = {
    .size = sizeof(box),
    .trait_descs = (__clawr_trait_descriptor*[]) { &HasStringRepresentation_trait },
    .trait_vtables = (void*[]) { &bitfield_HasStringRepresentation_vtable },
    .trait_count = 1
};
static const __clawr_type_info __bitfield_box_info = { .data = &__bitfield_box_data_type };

static inline bitfield leftShift(bitfield const self, integer const steps) {
    return self << steps;
}

#endif /* CLAWR_STDLIB_H */
