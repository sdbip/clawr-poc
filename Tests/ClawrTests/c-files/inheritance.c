#include "clawr-stdlib.h"
#include "clawr-runtime.h"

// object abstract Super {
//     func value() => self.value
//     mutating: func setValue(_ value: integer) { self.value = value }
//     data: value: integer
// }

// data: value: integer
struct __Super_data { integer value; };
typedef struct Super {
    struct __oo_rc_header header;
    struct __Super_data Super;
} Super;
typedef struct __Super_vtable {
// func setValue(_ value: integer)
    void (*setValue)(Super*, integer);
// func value() -> integer
    integer (*value)(Super*);
} __Super_vtable;

// factory: func new(value: integer) => { value: value }
void* Super_new_value(Super* self, integer value) {
    self->Super.value = value;
}

// func setValue(_ value: integer) { self.value = value }
void Super_setValue(Super* self, integer value) {
    self->Super.value = value;
}
//  func value() => self.value
integer Super_value(Super* self) {
    return self->Super.value;
}
__Super_vtable super_vtable = {
    .setValue = Super_setValue,
    .value = Super_value,
};

__oo_object_type __Super_object_type = {
    .size = sizeof(Super),
    .vtable = &super_vtable,
};
__oo_type_info __Super_info = { .object = &__Super_object_type };

// object Object: Super {
//     func objectValue() => self.value
// factory:
//     func new(value: integer) => {
//         super.new(value: value)
//         value: value
//     }
// mutating:
//     func setObjectValue(value: integer) { self.value = value }
// data:
//     value: integer
// }

// data: value: integer
struct __Object_data { integer value; };
typedef struct Object {
    struct __oo_rc_header header;
    struct __Super_data Super;
    struct __Object_data Object;
} Object;

// factory: func new(value: integer) => {
//     super.new(value: value)
//     value: value
// }
void* Object_new_value(void* self, integer value) {
    ((Object*)self)->Object.value = value;
    Super_new_value(self, value);
}

// mutating: func setObjectValue(value: integer) { self.value = value }
void Object_setObjectValue(Object* self, integer value) {
    self->Object.value = value;
}
// func objectValue() => self.value
integer Object_objectValue(Object* self) {
    return self->Object.value;
}

__oo_object_type __Object_object_type = {
    .size = sizeof(Object),
    .super = &__Super_object_type,
    .vtable = &super_vtable,
};
__oo_type_info __Object_info = { .object = &__Object_object_type };

int main() {

    // mut x = Object.new(value: 42)
    Object* x = oo_alloc(__oo_ISOLATED, __Object_info);
    Object_new_value(x, 42);

    // mut y = x
    Object* y = oo_retain(x);

    // x.setValue(2)
    x = oo_preModify(x);
    ((__Super_vtable*)x->header.is_a.object->vtable)->setValue(x, 2);

    // x.setObjectValue(12)
    x = oo_preModify(x); // Can be removed by optimiser if it can prove that the RC is 1 here
    Object_setObjectValue(x, 12);

    // print y.objectValue()
    box* box1 = __oo_make_box(Object_objectValue(y), __integer_box_info);
    print(box1);
    box1 = oo_release(box1);

    // print y.value()
    box* box2 = __oo_make_box(((__Super_vtable*)y->header.is_a.object->vtable)->value(y), __integer_box_info);
    print(box2);
    box2 = oo_release(box2);

    // print x.objectValue()
    box* box3 = __oo_make_box(Object_objectValue(x), __integer_box_info);
    print(box3);
    box3 = oo_release(box3);

    // print x.value()
    box* box4 = __oo_make_box(((__Super_vtable*)x->header.is_a.object->vtable)->value(x), __integer_box_info);
    print(box4);
    box4 = oo_release(box4);

    x = oo_release(x);
    y = oo_release(y);
    return 0;
}
