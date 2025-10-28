#include "oo-stdlib.h"

int main() {
    // print "string"
    string* s = string_format("string");
    print(s);
    free(s);
    return 0;
}
