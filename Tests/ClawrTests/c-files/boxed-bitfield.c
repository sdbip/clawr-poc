#include "clawr-stdlib.h"
#include "clawr-runtime.h"

int main() {
    // let bf: bitfield = 0x12
    box* bf = (box*) __clawr_make_box(0x0123456789abcdef, __bitfield_box_info);

    // print bf
    print(bf);

    bf = oo_release(bf);
    return 0;
}
