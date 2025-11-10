#include "clawr-stdlib.h"

int main() {
    printf("Bitfields contain 16 hex digits (64 bits). Their representation is always 21 characters long with grouping\n");
    // print 0x0012
    string* const s = bitfield_toString(0x0012);
    print(s);
    oo_release(s);
    return 0;
}
