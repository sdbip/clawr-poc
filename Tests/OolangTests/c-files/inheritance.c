#include "oo-stdlib.h"
#include "oo-runtime.h"

//        object abstract Super {
//            func value() => self.value
//            mutating: func setValue(_ value: integer) { self.value = value }
//            data: value: integer
//        }
struct __Super_data { integer value; };
typedef struct Super {
    struct __oo_rc_header header;
    struct __Super_data Super;
} Super;
typedef struct __Super_vtable {
//        func setValue(_ value: integer)
    void (*setValue)(Super* self, integer value);
//        func value() -> integer
    integer (*value)(Super* self);
} __Super_vtable;

//        func setValue(_ value: integer) { self.value = value }
void Super_setValue(Super* self, integer value) {
    self->Super.value = value;
}
//        func value() => self.value
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

//        object Object: Super {
//            func objectValue() => self.value
//        mutating:
//            func setObjectValue(value: integer) { self.value = value }
//        data:
//            value: integer
//        }
struct __Object_data { integer value; };
typedef struct Object {
    struct __oo_rc_header header;
    struct __Super_data Super;
    struct __Object_data Object;
} Object;
typedef struct __Object_vtable {
    // Super methods repeated
    void (*setValue)(Super* self, integer value);
    integer (*value)(Super* self);
//        func objectValue() -> integer
    void (*setObjectValue)(Object* self, integer value);
//        func setObjectValue(value: integer)
    integer (*objectValue)(Object* self);
} __Object_vtable;

//        func setObjectValue(value: integer) { self.value = value }
void Object_setObjectValue(Object* self, integer value) {
    self->Object.value = value;
}
//        func objectValue() => self.value
integer Object_objectValue(Object* self) {
    return self->Object.value;
}

__Object_vtable object_vtable = {
    .value = Super_value, // not overridden
    .setValue = Super_setValue, // not overridden
    .setObjectValue = Object_setObjectValue,
    .objectValue = Object_objectValue,
};
__oo_object_type __Object_object_type = {
    .size = sizeof(Object),
    .super = &__Super_object_type,
    .vtable = &object_vtable,
};
__oo_type_info __Object_info = { .object = &__Object_object_type };

int main() {
    __Object_vtable* x_vtable = NULL;
    __Object_vtable* y_vtable = NULL;

//        mut x = Object.new(value: 42)
    Object* x = oo_alloc(__oo_ISOLATED, __Object_info);
    x->Object.value = 42;
    x->Super.value = 42;
    x_vtable = x->header.is_a.object->vtable; // Can be removed by optimizer if it can prove that it is not used before oo_preModify call

//        mut y = x
    Object* y = oo_retain(x);
    y_vtable = y->header.is_a.object->vtable;

//        x.setValue(2)
    x = oo_preModify(x);
    x_vtable = x->header.is_a.object->vtable;
    x_vtable->setValue(x, 2);

//        x.setObjectValue(12)
    x = oo_preModify(x); // Can be removed by optimiser if it can prove that the RC is 1 here
    x_vtable = x->header.is_a.object->vtable; // Can be removed by optimiser if oo_preModify call is removed
    x_vtable->setObjectValue(x, 12);

//        print y.superValue()
    box* box1 = __oo_make_box(y->Object.value, __integer_box_info);
    print(box1);
    box1 = oo_release(box1);

    box* box2 = __oo_make_box(y->Super.value, __integer_box_info);
    print(box2);
    box2 = oo_release(box2);

    box* box3 = __oo_make_box(x->Object.value, __integer_box_info);
    print(box3);
    box3 = oo_release(box3);

    box* box4 = __oo_make_box(x->Super.value, __integer_box_info);
    print(box4);
    box4 = oo_release(box4);

    x = oo_release(x);
    y = oo_release(y);
    return 0;
}
