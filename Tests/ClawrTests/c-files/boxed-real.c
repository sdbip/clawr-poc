#include "clawr-stdlib.h"
#include "clawr-runtime.h"

int main() {
    // let r: bitfield = 12.0
    box* r = (box*) __oo_make_box(12.0, __real_box_info);

    // print r
    print(r);

    r = oo_release(r);
    return 0;
}
