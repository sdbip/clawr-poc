import Testing
import Codegen

@Suite("Traits")
struct TraitsTests {
    @Test("Generates data struct with single field")
    func data_struct_single_field() async throws {
        let output = codegen(ir: [.data(name: "Struct", fields: [Field(type: "integer", name: "value")])])
        #expect(output == """
            struct __Struct_data { integer value; };
            typedef struct Struct {
                struct __oo_rc_header header;
                struct __Struct_data StructData;
            } Struct;
            """)
    }

    @Test("Generates trait declaration code")
    func trait_declaration() async throws {
        let output = codegen(ir: [.traitDeclaration(
            name: "HasStringRepresentation",
            methods: [Function(
                name: "toString",
                returnType: "string*",
                parameters: [Field(type: "void*", name: "self")],
            )],
        )])
        #expect(output == """
            typedef struct HasStringRepresentation_vtable {
                string* (*toString)(void* self);
            } HasStringRepresentation_vtable;
            static const __oo_trait_descriptor HasStringRepresentation_trait = { .name = "HasStringRepresentation" };
            """)
    }

    @Test("Generates trait implementation code")
    func trait_conformance() async throws {
        let output = codegen(ir: [.traitImplementations(target: "Struct", traits: [Trait(name: "HasStringRepresentation", methods: ["toString"])])])
        #expect(output == """
            HasStringRepresentation_vtable Struct_HasStringRepresentation_vtable = {
                .toString = Struct_toString
            };

            __oo_data_type __Struct_data_type = {
                .size = sizeof(Struct),
                .trait_descs = (__oo_trait_descriptor*[]) { &HasStringRepresentation_trait },
                .trait_vtables = (void*[]) { &Struct_HasStringRepresentation_vtable },
                .trait_count = 1
            };
            __oo_type_info __Struct_info = { .data = &__Struct_data_type };
            """)
    }
}
