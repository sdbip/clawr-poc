#include "oo-stdlib.h"

int main() {
    printf("Bitfields contain 16 hex bits. Their representation is always 18 characters long\n");
    // print 0x0012
    string* const s = bitfield_toString(0x0012);
    print(s);
    free(s);
    return 0;
}
