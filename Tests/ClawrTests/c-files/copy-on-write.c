#include "clawr-stdlib.h"
#include "clawr-runtime.h"

//        data Struct { value: integer }
typedef struct {
    __clawr_rc_header header;
    struct { integer value; } Struct;
} Struct;
__clawr_data_type __Struct_data_type = {.size = sizeof(Struct)};
__clawr_type_info __Struct_info = {.data = &__Struct_data_type};

int main() {
//        mut x: Struct = { value: 42 }
    Struct* x = allocRC(__Struct_info, __clawr_ISOLATED);
    x->Struct.value = 42;

//        let y = x
    Struct* y = retainRC(x);

//        x.value = 2
    x = isolateRC(x);
    x->Struct.value = 2;

//        print y.value
    box* ybox = __clawr_make_box(y->Struct.value, __integer_box_info);
    print(ybox);
    ybox = releaseRC(ybox);

    box* xbox = __clawr_make_box(x->Struct.value, __integer_box_info);
    print(xbox);
    xbox = releaseRC(xbox);

    x = releaseRC(x);
    y = releaseRC(y);
    return 0;
}
