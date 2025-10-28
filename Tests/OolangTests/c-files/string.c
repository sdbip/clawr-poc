#include "oo-stdlib.h"

int main() {
    // print "string"
    string* s = string_format("string");
    printf("%s\n", s->buffer);

    free(s);
    return 0;
}
