#include "clawr-stdlib.h"
#include "clawr-runtime.h"

//        data Struct { value: integer }
typedef struct {
    __clawr_rc_header header;
    struct { integer value; } Struct;
} Struct;

//        model Struct: HasStringRepresentation {
//            func toString() => self.value().toString()
//        }
string* Struct_toString(void* self) {
    box* box = __clawr_make_box(((Struct*)self)->Struct.value, __integer_box_info);
    HasStringRepresentation_vtable* vtable = __clawr_trait_vtable(box, &HasStringRepresentation_trait);
    string* result = vtable->toString(box);
    box = releaseRC(box);
    return result;
}

HasStringRepresentation_vtable Struct_HasStringRepresentation_vtable = {
    .toString = Struct_toString
};

__clawr_data_type __Struct_data_type = {
    .size = sizeof(Struct),
    .trait_descs = (__clawr_trait_descriptor*[]) { &HasStringRepresentation_trait },
    .trait_vtables = (void*[]) { &Struct_HasStringRepresentation_vtable },
    .trait_count = 1
};
__clawr_type_info __Struct_info = {
    .data = &__Struct_data_type
};

int main() {
    //        let x: Struct = { value: 42 }
    Struct* x = allocRC(__Struct_info, __clawr_ISOLATED);
    x->Struct.value = 42;
//        print x
    print(x);

    x = releaseRC(x);
    return 0;
}
