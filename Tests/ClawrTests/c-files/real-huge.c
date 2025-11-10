#include "clawr-stdlib.h"
#include "clawr-runtime.h"

int main() {
//        print 4_200_000_000_000.0
    string* s = real_toString(4200000000000);
    print(s);
    s = oo_release(s);
    return 0;
}
