#include <inttypes.h> // PRIx64, uint64_t, int64_t
#include <stdio.h>    // printf

typedef uint64_t bitfield;

/// @brief Implementation of bitfield.print()
/// @param self the target bitfield “object”
static inline void bitfield_print(bitfield self) {
    // Print using "0x" prefix and 16 hex digits
    printf("%#018" PRIx64 "\n", self);
}
