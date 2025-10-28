#include "oo-stdlib.h"
#include "oo-runtime.h"

int main() {
    // let bf: bitfield = 0x12
    box* bf = (box*) __oo_make_box(0x12, &__bitfield_box_info);

    // print bf
    print_desc(bf);

    bf = oo_release(bf);
    return 0;
}
