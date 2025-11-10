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
                        Field(type: .simple("__clawr_rc_header"), name: "header"),
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
                                .name("__clawr_make_box"),
                                arguments: [
                                    .reference(
                                        .field(
                                            target: .reference(.field(
                                                target: .cast(.reference(.name("self")), type: "Struct*"),
                                                name: "StructData",
                                                isPointer: true
                                            )),
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
                                .name("__clawr_trait_vtable"),
                                arguments: [
                                    .literal("box"),
                                    .reference(.address(of: .name("HasStringRepresentation_trait"))),
                                ]
                            )
                        ),
                        .variable(
                            "result",
                            type: "string*",
                            initializer: .call(
                                .field(
                                    target: .reference(.name("vtable")),
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
                    type: "__clawr_data_type",
                    initializer: .structInitializer([
                        NamedValue(name: "size", value: .call(.name("sizeof"), arguments: [.reference(.name("Struct"))])),
                        NamedValue(
                            name: "trait_descs",
                            value: .arrayInitializer([
                                .reference(.address(of: .name("HasStringRepresentation_trait"))),
                            ]),
                        ),
                        NamedValue(
                            name: "trait_vtables",
                            value: .arrayInitializer([
                                .reference(.address(of: .name("Struct_HasStringRepresentation_vtable"))),
                            ]),
                        ),
                        NamedValue(name: "trait_count", value: .literal("1"))
                    ])
                ),
                .variable(
                    "__Struct_info",
                    type: "__clawr_type_info",
                    initializer: .structInitializer([
                        NamedValue(name: "data", value: .reference(.address(of: .name("__Struct_data_type")))),
                    ])
                ),
                exec([
                    .variable(
                        "x",
                        type: "Struct*",
                        initializer: .call(
                            .name("oo_alloc"),
                            arguments: [
                                .literal("__clawr_ISOLATED"),
                                .literal("__Struct_info"),
                            ]
                        )
                    ),
                    .assign(
                        .field(
                            target: .reference(.field(
                                target: .reference(.name("x")),
                                name: "StructData",
                                isPointer: true
                            )),
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
