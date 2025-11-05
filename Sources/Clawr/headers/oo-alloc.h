#ifndef OO_ALLOC_H
#define OO_ALLOC_H

#include <stdio.h>    // fprintf
#include <stdlib.h>   // malloc, size_t, NULL

static inline void* __oo_alloc(size_t size) {
    void* const memory = malloc(size);
    if (memory == NULL) {
        // TODO: Allow user to manage memory.
        fprintf(stderr, "Out of memory!");
        exit(EXIT_FAILURE);
    }
    return memory;
}

#endif /*.OO_ALLOC_H */
