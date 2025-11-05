#include "oo-stdlib.h"
#include "oo-runtime.h"

int main() {
//        print 42
    string* const s = integer_toString(42);
    print(s);
    oo_release(s);
    return 0;
}
