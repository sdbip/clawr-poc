import Testing
import Codegen

@Suite("Codegen")
struct CodegenTests {
    @Test("Generates data struct with single field")
    func data_struct_single_field() async throws {
        let output = codegen(ir: .data(name: "Struct", fields: [Field(type: "integer", name: "value")]))
        #expect(output == """
            struct __Struct_data { integer value; };
            typedef struct Struct {
                struct __oo_rc_header header;
                struct __Struct_data StructData;
            } Struct;
            """)
    }
}
