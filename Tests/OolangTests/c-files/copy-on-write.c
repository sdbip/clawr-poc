#include "oo-stdlib.h"
#include "oo-runtime.h"

//        data Struct { value: integer }
struct __Struct_data { integer value; };
typedef struct Struct {
    struct __oo_rc_header header;
    struct __Struct_data Struct;
} Struct;
__oo_data_type __Struct_data_type = {.size = sizeof(Struct)};
__oo_type_info __Struct_info = {.data = &__Struct_data_type};

int main() {
//        mut x: Struct = { value: 42 }
    Struct* x = oo_alloc(__oo_ISOLATED, __Struct_info);
    x->Struct.value = 42;

//        let y = x
    Struct* y = oo_retain(x);

//        x.value = 2
    x = oo_preModify(x);
    x->Struct.value = 2;

//        print y.value
    box* ybox = __oo_make_box(y->Struct.value, __integer_box_info);
    print(ybox);
    ybox = oo_release(ybox);

    box* xbox = __oo_make_box(x->Struct.value, __integer_box_info);
    print(xbox);
    xbox = oo_release(xbox);

    x = oo_release(x);
    y = oo_release(y);
    return 0;
}
