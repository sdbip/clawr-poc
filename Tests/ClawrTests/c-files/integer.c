#include "clawr-stdlib.h"
#include "clawr-runtime.h"

int main() {
//        print 42
    string* const s = integer_toString(42);
    print(s);
    oo_release(s);
    return 0;
}
