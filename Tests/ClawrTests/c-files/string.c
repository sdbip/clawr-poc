#include "clawr-stdlib.h"

int main() {
    // print "string"
    string* s = string_format("string");
    print(s);
    oo_release(s);
    return 0;
}
