#include "oo-stdlib.h"
#include "oo-runtime.h"

int main() {
//        print 0.000_000_000_42
    string* s = real_toString(0.00000000042);
    print(s);
    s = oo_release(s);
    return 0;
}
