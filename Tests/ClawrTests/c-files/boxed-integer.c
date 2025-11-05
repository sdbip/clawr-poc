#include "oo-stdlib.h"
#include "oo-runtime.h"

int main() {
    // let i: integer = 42
    box* i = (box*) __oo_make_box(42, __integer_box_info);

    // print i
    print(i);

    i = oo_release(i);
    return 0;
}
