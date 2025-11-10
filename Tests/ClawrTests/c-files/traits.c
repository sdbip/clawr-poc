#include "clawr-stdlib.h"
#include "clawr-runtime.h"

//        struct Struct { value: integer }
struct __Struct_data { integer value; };
typedef struct Struct {
    struct __oo_rc_header header;
    struct __Struct_data Struct;
} Struct;

//        model Struct: HasStringRepresentation {
//            func toString() => self.value().toString()
//        }
string* Struct_toString(void* self) {
    box* box = __oo_make_box(((Struct*)self)->Struct.value, __integer_box_info);
    HasStringRepresentation_vtable* vtable = __oo_trait_vtable(box, &HasStringRepresentation_trait);
    string* result = vtable->toString(box);
    box = oo_release(box);
    return result;
}

HasStringRepresentation_vtable Struct_HasStringRepresentation_vtable = {
    .toString = Struct_toString
};

__oo_data_type __Struct_data_type = {
    .size = sizeof(Struct),
    .trait_descs = (__oo_trait_descriptor*[]) { &HasStringRepresentation_trait },
    .trait_vtables = (void*[]) { &Struct_HasStringRepresentation_vtable },
    .trait_count = 1
};
__oo_type_info __Struct_info = {
    .data = &__Struct_data_type
};

int main() {
    //        let x: Struct = { value: 42 }
    Struct* x = oo_alloc(__oo_ISOLATED, __Struct_info);
    x->Struct.value = 42;
//        print x
    print(x);

    x = oo_release(x);
    return 0;
}
