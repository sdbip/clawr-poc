import Testing
import Lexer
@testable import Parser

@Suite("Object Declarations")
struct ObjectDeclarationTests {

    @Test(arguments: ["object", "object O", "object O {"])
    func unexpected_end(_ source: String) async throws {
        let error = try #require(throws: ParserError.self) { try parse(source) }
        guard case .unexpectedEOF = error else {
            Issue.record("Did not throw the expected error, was: \(error)")
            return
        }
    }

    @Test(arguments: ["object 12 {}", "object S 1"])
    func invalid_token(_ source: String) async throws {
        let error = try #require(throws: ParserError.self) { try parse(source)}
        guard case .invalidToken = error else {
            Issue.record("Did not throw the expected error, was: \(error)")
            return
        }
    }

    @Test(arguments: ["object O {data:data:}", "object S {static:static:}", "object S {mutating:mutating:}", "object S {factory:factory:}"])
    func repeated_section(_ source: String) async throws {
        let error = try #require(throws: ParserError.self) { try parse(source)}
        guard case .invalidToken(_) = error else {
            Issue.record("Did not throw the expected error, was: \(error)")
            return
        }
    }

    @Test(arguments: [
        "object O {mutating:}",
        "object O {static:}",
        "object O {data:}",
        "object O {mutating:data:}",
        "object O {static:mutating:}",
        "object O {static:factory:}",
        "object O {factory:mutating:}",
        "object O {data:static:}",
    ])
    func empty_sections(source: String) async throws {
        _ = try parse(source)
    }

    @Test
    func empty_object() async throws {
        let ast = try parse("object S {}")
        #expect(ast == [.objectDeclaration(Object(
            name: "S",
        ))])
    }

    @Test
    func single_field() async throws {
        let ast = try parse("object S { data: x: integer }")
        #expect(ast == [.objectDeclaration(Object(
            name: "S",
            fields: [Variable(name: "x", semantics: .isolated, type: .builtin(.integer))],
        ))])
    }

    @Test
    func multiple_fields_on_single_line() async throws {
        let ast = try parse("object S { data: x: integer, y: bitfield }")
        #expect(ast == [.objectDeclaration(Object(
            name: "S",
            fields: [
                Variable(name: "x", semantics: .isolated, type: .builtin(.integer)),
                Variable(name: "y", semantics: .isolated, type: .builtin(.bitfield)),
            ],
        ))])
    }

    @Test
    func multiple_fields_with_newline_separator() async throws {
        let source = """
            object S {
            data:
                x: integer
                y: bitfield
            }
            """
        let ast = try parse(source)
        #expect(ast == [.objectDeclaration(Object(
            name: "S",
            fields: [
                Variable(name: "x", semantics: .isolated, type: .builtin(.integer)),
                Variable(name: "y", semantics: .isolated, type: .builtin(.bitfield)),
            ],
        ))])
    }

    @Test
    func multiple_fields_with_trailing_comma() async throws {
        let source = "object S { data: x: integer, y: bitfield, }"
        let ast = try parse(source)
        #expect(ast == [.objectDeclaration(Object(
            name: "S",
            fields: [
                Variable(name: "x", semantics: .isolated, type: .builtin(.integer)),
                Variable(name: "y", semantics: .isolated, type: .builtin(.bitfield)),
            ],
        ))])
    }

    @Test
    func single_method() async throws {
        let source = "object S { pure method() => 42 }"
        let ast = try parse(source)
        #expect(ast == [.objectDeclaration(Object(
            name: "S",
            methods: [Function(name: "method", isPure: true, returnType: .builtin(.integer), parameters: [], body: [.returnStatement(.integer(42))])],
        ))])
    }

    @Test
    func multiple_methods() async throws {
        let source = """
            object S {
                pure method1() => 42
                pure method2() => 43
            }
            """
        let ast = try parse(source)
        #expect(ast == [.objectDeclaration(Object(
            name: "S",
            methods: [
                Function(name: "method1", isPure: true, returnType: .builtin(.integer), parameters: [], body: [.returnStatement(.integer(42))]),
                Function(name: "method2", isPure: true, returnType: .builtin(.integer), parameters: [], body: [.returnStatement(.integer(43))]),
            ],
        ))])
    }

    @Test
    func field_lookup() async throws {
        let source = """
            object S {
                pure method() => self.answer
            data:
                let answer = 42
            }
            """
        let ast = try parse(source)
        guard case .objectDeclaration(let object) = ast.first else { Issue.record("Expected object declaration in \(ast)"); return }
        guard case .returnStatement(let expr) = object.methods.first?.body.first else { Issue.record("Expected return statement in \(object.methods.first)"); return }
        #expect(object.methods.first?.isPure == true)
        #expect(expr == .memberLookup(
            .identifier(
                "self",
                type: .object(object)
            ),
            member: "answer",
            type: .builtin(.integer)
        ))
    }

    @Test
    func mutating_method() async throws {
        let source = "object S { mutating: func method1() {} }"
        let ast = try parse(source)
        #expect(ast == [.objectDeclaration(Object(
            name: "S",
            methods: [
                Function(name: "method1", isPure: false, returnType: nil, parameters: [], body: []),
            ],
        ))])
    }

    @Test
    func factory_methods() async throws {
        let source = "object S { factory: func new() => {} }"
        let ast = try parse(source)
        guard case .objectDeclaration(let object) = ast.first else { Issue.record("Expected object declaration in \(ast)"); return }
        #expect(object.name == "S")
        #expect(object.factoryMethods == [
            Function(
                name: "new",
                isPure: false,
                returnType: .object(object),
                parameters: [],
                body: [.returnStatement(.dataStructureLiteral(.object(object), fieldValues: [:]))]
            ),
        ])
    }

    @Test
    func static_fields() async throws {
        let source = "object LifeTheUniverseAndEverything { static: let answer = 42 }"
        let ast = try parse(source)
        guard case .objectDeclaration(let object) = ast.first else { Issue.record("Expected an object from \(ast)"); return }
        #expect(object.companion?.fields == [Variable(name: "answer", semantics: .immutable, type: .builtin(.integer), initialValue: .integer(42))])
    }

    @Test
    func static_field_lookup() async throws {
        let source = """
            object S {
            static:
                let answer = 42
                func method() => S.answer
            }
            """
        let ast = try parse(source)
        guard case .objectDeclaration(let object) = ast.first else { Issue.record("Expected an object from \(ast)"); return }
        guard let companion = object.companion else { Issue.record("Expected a companion object from \(object)"); return }
        guard case .returnStatement(let stmt) = object.companion?.methods.first?.body.first else { Issue.record("Expected an return statement in \(object.companion?.methods.first)"); return }
        #expect(companion.methods.first?.isPure == false)
        #expect(stmt == .memberLookup(
            .identifier(
                "S",
                type: .companionObject(companion)
            ),
            member: "answer",
            type: .builtin(.integer)
        ))

        #expect(object.companion?.methods.count == 1)
        #expect(object.companion?.methods.first?.name == "method")
        #expect(object.companion?.methods.first?.returnType == .builtin(.integer))
        #expect(object.companion?.methods.first?.body.count == 1)
        #expect(object.companion?.methods.first?.parameters.count == 0)
    }

    @Test
    func static_field_lookup_from_instance_scope() async throws {
        let source = """
            object S {
                pure method() => S.answer
            static:
                let answer = 42
            }
            """
        let ast = try parse(source)
        guard case .objectDeclaration(let object) = ast.first else { Issue.record("Expected an object from \(ast)"); return }
        guard case .returnStatement(let stmt) = object.methods.first?.body.first else { Issue.record("Expected an return statement in \(object.methods.first)"); return }
        #expect(stmt == .memberLookup(
            .identifier(
                "S",
                type: .companionObject(CompanionObject(
                    name: "S_static",
                    fields: [Variable(name: "answer", semantics: .immutable, type: .builtin(.integer), initialValue: .integer(42))]
                ))
            ),
            member: "answer",
            type: .builtin(.integer)
        ))

        #expect(object.methods.count == 1)
        #expect(object.methods.first?.name == "method")
        #expect(object.methods.first?.isPure == true)
        #expect(object.methods.first?.returnType == .builtin(.integer))
        #expect(object.methods.first?.body.count == 1)
        #expect(object.methods.first?.parameters.count == 0)
    }

    @Test
    func supertype() async throws {
        let source = """
            object Super {}
            object Inheritor: Super {}
            """
        let ast = try parse(source)
        #expect(ast.last == .objectDeclaration(Object(
            name: "Inheritor",
            isAbstract: false,
            supertype: .object(Object(name: "Super")),
        )))
    }

    @Test
    func abstract_object() async throws {
        let source = "object abstract S {}"
        let ast = try parse(source)
        #expect(ast == [.objectDeclaration(Object(
            name: "S",
            isAbstract: true,
            supertype: nil,
        ))])
    }
}
