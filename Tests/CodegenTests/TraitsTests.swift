import Testing
import Codegen

@Suite("Traits")
struct TraitsTests {

    @Test("Conform to traits")
    func traits() async throws {
        let result = try run(
            ir: [
                .structDeclaration(
                    "__Struct_data", 
                    fields: [Field(type: .simple("integer"), name: "value")]
                ),
                .structDeclaration(
                    "Struct", 
                    fields: [
                        Field(type: .simple("__oo_rc_header"), name: "header"),
                        Field(type: .simple("__Struct_data"), name: "StructData"),
                    ]
                ),
                .function(
                    "Struct_toString",
                    returns: "string*",
                    parameters: [
                        Field(
                            type: .simple("void*"),
                            name: "self"
                        )
                    ],
                    body: [
                        .variable(
                            "box",
                            type: "box*",
                            initializer: .call(
                                .name("__oo_make_box"),
                                arguments: [
                                    .reference(
                                        .field(
                                            target: .field(
                                                target: .cast(.name("self"), type: "Struct*"),
                                                name: "StructData",
                                                isPointer: true),
                                            name: "value",
                                            isPointer: false),
                                    ),
                                    .literal("__integer_box_info"),
                                ]
                            )
                        ),
                        .variable(
                            "vtable",
                            type: "HasStringRepresentation_vtable*",
                            initializer: .call(
                                .name("__oo_trait_vtable"),
                                arguments: [
                                    .literal("box"),
                                    .literal("&HasStringRepresentation_trait"),
                                ]
                            )
                        ),
                        .variable(
                            "result",
                            type: "string*",
                            initializer: .call(
                                .field(
                                    target: .name("vtable"),
                                    name: "toString",
                                    isPointer: true
                                ),
                                arguments: [.reference(.name("box"))]
                            )
                        ),
                        .assign(
                            .name("box"),
                            value: .call(
                                .name("oo_release"),
                                arguments: [.literal("box")]
                            )
                        ),
                        .return(.literal("result")),
                    ]
                ),
                .variable(
                    "Struct_HasStringRepresentation_vtable", 
                    type: "HasStringRepresentation_vtable", 
                    initializer: .structInitializer([
                        NamedValue(
                            name: "toString", 
                            value: .reference(.name("Struct_toString"))
                        )
                    ])
                ),
                .variable(
                    "__Struct_data_type", 
                    type: "__oo_data_type", 
                    initializer: .structInitializer([
                        NamedValue(name: "size", value: .literal("sizeof(Struct)")),
                        NamedValue(
                            name: "trait_descs", 
                            value: .literal("(void*[]) { \( ["HasStringRepresentation_trait"].map { "&\($0)" }.joined(separator: ", ") ) }")
                        ),
                        NamedValue(
                            name: "trait_vtables", 
                            value: .literal("(void*[]) { \( ["Struct_HasStringRepresentation_vtable"].map { "&\($0)" }.joined(separator: ", ") ) }")
                        ),
                        NamedValue(name: "trait_count", value: .literal("1"))
                    ])
                ),
                .variable(
                    "__Struct_info", 
                    type: "__oo_type_info", 
                    initializer: .structInitializer([
                        NamedValue(name: "data", value: .literal("&__Struct_data_type")),
                    ])
                ),
                exec([
                    .variable(
                        "x",
                        type: "Struct*",
                        initializer: .call(
                            .name("oo_alloc"),
                            arguments: [
                                .literal("__oo_ISOLATED"),
                                .literal("__Struct_info"),
                            ]
                        )
                    ),
                    .assign(
                        .field(
                            target: .field(
                                target: .name("x"),
                                name: "StructData",
                                isPointer: true),
                            name: "value",
                            isPointer: false
                        ),
                        value: .literal("42")
                    ),
                    .call(
                        .name("print"),
                        arguments: [.literal("x")]
                    ),
                    .assign(
                        .name("x"),
                        value: .call(
                            .name("oo_release"),
                            arguments: [.literal("x")]
                        )
                    ),
                ])
            ])
        #expect(result == "42\n")
    }
}
