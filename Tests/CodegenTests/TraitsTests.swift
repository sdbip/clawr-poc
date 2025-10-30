import Testing
import Codegen

@Suite("Traits")
struct TraitsTests {

    @Test("Conform to traits")
    func traits() async throws {
        let result = try run(
            ir: [
                .data(
                    name: "Struct",
                    fields: [Field(type: "integer", name: "value")]
                ),
                .function(
                    "Struct_toString",
                    returns: "string*",
                    parameters: [
                        Field(
                            type: "void*",
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
                .traitConformances(
                    target: "Struct",
                    traits: [Trait(
                        name: "HasStringRepresentation",
                        methods: ["toString"])
                    ]
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
