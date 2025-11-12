import Testing
import Codegen

@Suite("Inheritance")
struct InheritanceTests {

    @Test("Inheritance chain")
    func inheritance() async throws {
        let superIR: [Statement] = [
            .structDeclaration(
                "__Super_data",
                fields: [Field(type: .simple("integer"), name: "value")]
            ),
            .structDeclaration(
                "Super",
                fields: [
                    Field(type: .simple("__clawr_rc_header"), name: "header"),
                    Field(type: .simple("__Super_data"), name: "SuperData"),
                ]
            ),
            .structDeclaration(
                "__Super_vtable",
                fields: [
                    Field(
                        type: .function(
                            returnType: "void",
                            parameters: ["Super*", "integer"]
                        ),
                        name: "setValue"),
                    Field(
                        type: .function(
                            returnType: "integer",
                            parameters: ["Super*"]
                        ),
                        name: "value",
                    ),
                ],
            ),
            .function(
                "Super_new_value",
                returns: "void",
                parameters: [
                    Field(type: .simple("Super*"), name: "self"),
                    Field(type: .simple("integer"), name: "value"),
                ],
                body: [.assign(
                    .field(
                        target: .reference(.field(
                            target: .reference(.name("self")),
                            name: "SuperData",
                            isPointer: true
                        )),
                        name: "value",
                        isPointer: false
                    ),
                    value: .reference(.name("value"))
                )]
            ),
            .function(
                "Super_setValue",
                returns: "void",
                parameters: [
                    Field(type: .simple("Super*"), name: "self"),
                    Field(type: .simple("integer"), name: "value"),
                ],
                body: [.assign(
                    .field(
                        target: .reference(.field(
                            target: .reference(.name("self")),
                            name: "SuperData",
                            isPointer: true
                        )),
                        name: "value",
                        isPointer: false
                    ),
                    value: .reference(.name("value"))
                )]
            ),
            .function(
                "Super_value",
                returns: "integer",
                parameters: [
                    Field(type: .simple("Super*"), name: "self"),
                ],
                body: [.return(
                    .reference(.field(
                        target: .reference(.field(
                            target: .reference(.name("self")),
                            name: "SuperData",
                            isPointer: true
                        )),
                        name: "value",
                        isPointer: false
                    ))
                )]
            ),
            .variable(
                "super_vtable",
                type: "static __Super_vtable const",
                initializer: .structInitializer([
                    NamedValue(name: "setValue", value: .reference(.name("Super_setValue"))),
                    NamedValue(name: "value", value: .reference(.name("Super_value"))),
                ])
            ),
            .variable(
                "__Super_object_type",
                type: "__clawr_object_type",
                initializer: .structInitializer([
                    NamedValue(name: "size", value: .call(.name("sizeof"), arguments: [.reference(.name("Super"))])),
                    NamedValue(name: "vtable", value: .reference(.address(of: .name("super_vtable")))),
                ])
            ),
            .variable(
                "__Super_info",
                type: "__clawr_type_info",
                initializer: .structInitializer([
                    NamedValue(name: "object", value: .reference(.address(of: .name("__Super_object_type")))),
                ])
            ),
        ]
        let objectIR: [Statement] = [
            .structDeclaration(
                "__Object_data",
                fields: [Field(type: .simple("integer"), name: "value")]
            ),
            .structDeclaration(
                "Object",
                fields: [
                    Field(type: .simple("__clawr_rc_header"), name: "header"),
                    Field(type: .simple("__Super_data"), name: "SuperData"),
                    Field(type: .simple("__Object_data"), name: "ObjectData"),
                ]
            ),
            .function(
                "Object_new_value",
                returns: "void",
                parameters: [
                    Field(type: .simple("Object*"), name: "self"),
                    Field(type: .simple("integer"), name: "value"),
                ],
                body: [
                    .assign(
                        .field(
                            target: .reference(.field(
                                target: .reference(.name("self")),
                                name: "ObjectData",
                                isPointer: true
                            )),
                            name: "value",
                            isPointer: false
                        ),
                        value: .reference(.name("value"))
                    ),
                    .call(
                        .name("Super_new_value"),
                        arguments: [
                            .reference(.name("self")),
                            .reference(.name("value")),
                        ]
                    )
                ]
            ),
            .function(
                "Object_setObjectValue",
                returns: "void",
                parameters: [
                    Field(type: .simple("Object*"), name: "self"),
                    Field(type: .simple("integer"), name: "value"),
                ],
                body: [.assign(
                    .field(
                        target: .reference(.field(
                            target: .reference(.name("self")),
                            name: "ObjectData",
                            isPointer: true
                        )),
                        name: "value",
                        isPointer: false
                    ),
                    value: .reference(.name("value"))
                )]
            ),
            .function(
                "Object_objectValue",
                returns: "integer",
                parameters: [
                    Field(type: .simple("Object*"), name: "self"),
                ],
                body: [.return(
                    .reference(.field(
                        target: .reference(.field(
                            target: .reference(.name("self")),
                            name: "ObjectData",
                            isPointer: true
                        )),
                        name: "value",
                        isPointer: false
                    ))
                )]
            ),
            .variable(
                "__Object_object_type",
                type: "__clawr_object_type",
                initializer: .structInitializer([
                    NamedValue(name: "size", value: .call(.name("sizeof"), arguments: [.reference(.name("Super"))])),
                    NamedValue(name: "super", value: .reference(.address(of: .name("__Super_object_type")))),
                    NamedValue(name: "vtable", value: .reference(.address(of: .name("super_vtable")))),
                ])
            ),
            .variable(
                "__Object_info",
                type: "__clawr_type_info",
                initializer: .structInitializer([
                    NamedValue(name: "object", value: .reference(.address(of: .name("__Object_object_type")))),
                ])
            ),
        ]

        let result = try run(ir: superIR
            .appending(contentsOf: objectIR)
            .appending(.function(
                "main",
                returns: "int",
                parameters: [],
                body: [
                    .variable(
                        "x",
                        type: "Object*",
                        initializer: .call(
                            .name("allocRC"),
                            arguments: [
                                .reference(.name("__Object_info")),
                                .reference(.name("__clawr_ISOLATED")),
                            ]
                        )
                    ),
                    .call(
                        .name("Object_new_value"),
                        arguments: [
                            .reference(.name("x")),
                            .literal("42"),
                        ]
                    ),
                    .variable(
                        "y",
                        type: "Object*",
                        initializer: .call(
                            .name("oo_retain"),
                            arguments: [
                                .reference(.name("x"))
                            ]
                        )
                    ),
                    .assign(
                        .name("x"),
                        value: .call(
                            .name("oo_preModify"),
                            arguments: [
                                .reference(.name("x"))
                            ]
                        )
                    ),
                    .call(
                        .field(
                            target: .cast(
                                .reference(.field(
                                    target: .reference(.field(
                                        target: .reference(.field(
                                            target: .reference(.field(
                                                target: .reference(.name("x")),
                                                name: "header",
                                                isPointer: true
                                            )),
                                            name: "is_a",
                                            isPointer: false
                                        )),
                                        name: "object",
                                        isPointer: false
                                    )),
                                    name: "vtable",
                                    isPointer: true
                                )),
                                type: "__Super_vtable*"
                            ),
                            name: "setValue",
                            isPointer: true
                        ),
                        arguments: [
                            .reference(.name("x")),
                            .literal("2"),
                        ]
                    ),
                    .assign(
                        .name("x"),
                        value: .call(
                            .name("oo_preModify"),
                            arguments: [
                                .reference(.name("x"))
                            ]
                        )
                    ),
                    .call(
                        .name("Object_setObjectValue"),
                        arguments: [
                            .reference(.name("x")),
                            .literal("12"),
                        ]
                    ),
                    .variable(
                        "box1",
                        type: "box*",
                        initializer: .call(
                            .name("__clawr_make_box"),
                            arguments: [
                                .call(
                                    .name("Object_objectValue"),
                                    arguments: [.reference(.name("y"))]
                                ),
                                .reference(.name("__integer_box_info"))
                            ]
                        )
                    ),
                    .call(
                        .name("print"),
                        arguments: [.reference(.name("box1"))]
                    ),
                    .assign(
                        .name("box1"),
                        value: .call(
                            .name("oo_release"),
                            arguments: [.reference(.name("box1"))]
                        )
                    ),
                    .variable(
                        "box2",
                        type: "box*",
                        initializer: .call(
                            .name("__clawr_make_box"),
                            arguments: [
                                .call(
                                    .field(
                                        target: .cast(
                                            .reference(.field(
                                                target: .reference(.field(
                                                    target: .reference(.field(
                                                        target: .reference(.field(
                                                            target: .reference(.name("y")),
                                                            name: "header",
                                                            isPointer: true
                                                        )),
                                                        name: "is_a",
                                                        isPointer: false
                                                    )),
                                                    name: "object",
                                                    isPointer: false
                                                )),
                                                name: "vtable",
                                                isPointer: true
                                            )),
                                            type: "__Super_vtable*"
                                        ),
                                        name: "value",
                                        isPointer: true
                                    ),
                                    arguments: [.reference(.name("y"))]
                                ),
                                .reference(.name("__integer_box_info"))
                            ]
                        )
                    ),
                    .call(
                        .name("print"),
                        arguments: [.reference(.name("box2"))]
                    ),
                    .assign(
                        .name("box2"),
                        value: .call(
                            .name("oo_release"),
                            arguments: [.reference(.name("box2"))]
                        )
                    ),
                    .variable(
                        "box3",
                        type: "box*",
                        initializer: .call(
                            .name("__clawr_make_box"),
                            arguments: [
                                .call(
                                    .name("Object_objectValue"),
                                    arguments: [.reference(.name("x"))]
                                ),
                                .reference(.name("__integer_box_info"))
                            ]
                        )
                    ),
                    .call(
                        .name("print"),
                        arguments: [.reference(.name("box3"))]
                    ),
                    .assign(
                        .name("box1"),
                        value: .call(
                            .name("oo_release"),
                            arguments: [.reference(.name("box3"))]
                        )
                    ),
                    .variable(
                        "box4",
                        type: "box*",
                        initializer: .call(
                            .name("__clawr_make_box"),
                            arguments: [
                                 .call(
                                    .field(
                                        target: .cast(
                                            .reference(.field(
                                                target: .reference(.field(
                                                    target: .reference(.field(
                                                        target: .reference(.field(
                                                            target: .reference(.name("x")),
                                                            name: "header",
                                                            isPointer: true
                                                        )),
                                                        name: "is_a",
                                                        isPointer: false
                                                    )),
                                                    name: "object",
                                                    isPointer: false
                                                )),
                                                name: "vtable",
                                                isPointer: true
                                            )),
                                            type: "__Super_vtable*"
                                        ),
                                        name: "value",
                                        isPointer: true
                                    ),
                                    arguments: [.reference(.name("x"))]
                                ),
                                .reference(.name("__integer_box_info"))
                           ]
                        )
                    ),
                    .call(
                        .name("print"),
                        arguments: [.reference(.name("box4"))]
                    ),
                    .assign(
                        .name("box4"),
                        value: .call(
                            .name("oo_release"),
                            arguments: [.reference(.name("box4"))]
                        )
                    ),
                    .assign(
                        .name("x"),
                        value: .call(
                            .name("oo_release"),
                            arguments: [.reference(.name("x"))]
                        )
                    ),
                    .assign(
                        .name("y"),
                        value: .call(
                            .name("oo_release"),
                            arguments: [.reference(.name("y"))]
                        )
                    ),
                ]
            ))
        )
        #expect(result == "42\n42\n12\n2\n")
    }
}
