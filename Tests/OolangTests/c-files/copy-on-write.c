#include "oo-stdlib.h"
#include "oo-runtime.h"

//        struct Struct { value: integer }
struct __Struct_data { int64_t value; };
typedef struct Struct {
    struct __oo_rc_header header;
    struct __Struct_data Struct;
} Struct;
__oo_struct_type __Struct_info = {.size = sizeof(Struct)};

int main() {
//        mut x: Struct = { value: 42 }
    Struct* x = oo_alloc(__oo_ISOLATED, &__Struct_info);
    x->Struct.value = 42;

//        let y = x
    Struct* y = oo_retain(&x->header);

//        x.value = 2
    x = oo_preModify(&x->header);
    x->Struct.value = 2;

//        print y.value
    string* sy = integer_toString(y->Struct.value);
    print(sy);
    sy = oo_release(sy);
    string* sx = integer_toString(x->Struct.value);
    print(sx);
    sx = oo_release(sx);

    x = oo_release(&x->header);
    y = oo_release(&y->header);
    return 0;
}
