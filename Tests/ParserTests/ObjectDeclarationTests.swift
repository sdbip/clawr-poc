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
        let ast = try parse(source)
        #expect(ast == [.objectDeclaration(Object(
            name: "O",
            isAbstract: false,
            supertype: nil,
            pureMethods: [],
            mutatingMethods: [],
            fields: [],
            staticMethods: [],
            staticFields: [],
        ))])
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
        let ast = try parse("""
            object S {
            data:
                x: integer
            }
            """)
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
        let source = "object S { func method() => 42 }"
        let ast = try parse(source)
        #expect(ast == [.objectDeclaration(Object(
            name: "S",
            pureMethods: [Function(name: "method", returnType: .builtin(.integer), parameters: [], body: [.returnStatement(.integer(42))])],
        ))])
    }

    @Test
    func multiple_methods() async throws {
        let source = """
            object S {
                func method1() => 42
                func method2() => 43
            }
            """
        let ast = try parse(source)
        #expect(ast == [.objectDeclaration(Object(
            name: "S",
            pureMethods: [
                Function(name: "method1", returnType: .builtin(.integer), parameters: [], body: [.returnStatement(.integer(42))]),
                Function(name: "method2", returnType: .builtin(.integer), parameters: [], body: [.returnStatement(.integer(43))]),
            ],
        ))])
    }

    @Test
    func mutating_method() async throws {
        let source = """
            object S {
            mutating:
                func method1() {}
            }
            """
        let ast = try parse(source)
        #expect(ast == [.objectDeclaration(Object(
            name: "S",
            mutatingMethods: [
                Function(name: "method1", returnType: nil, parameters: [], body: []),
            ],
        ))])
    }

    @Test
    func static_methods() async throws {
        let source = """
            object S {
            static:
                func method1() => 42
                func method2() => 43
            }
            """
        let ast = try parse(source)
        #expect(ast == [.objectDeclaration(Object(
            name: "S",
            staticMethods: [
                Function(name: "method1", returnType: .builtin(.integer), parameters: [], body: [.returnStatement(.integer(42))]),
                Function(name: "method2", returnType: .builtin(.integer), parameters: [], body: [.returnStatement(.integer(43))]),
            ],
        ))])
    }

    @Test
    func factory_methods() async throws {
        let source = """
            object S {
            factory:
                func new() => {}
            }
            """
        let ast = try parse(source)
        #expect(ast == [.objectDeclaration(Object(
            name: "S",
            factoryMethods: [
                Function(name: "new", returnType: .object(Object(name: "S")), parameters: [], body: [.returnStatement(.dataStructureLiteral(.object(Object(name: "S")), fieldValues: [:]))]),
            ],
        ))])
    }

    @Test
    func static_fields() async throws {
        let source = """
            object LifeTheUniverseAndEverything {
            static:
                let answer = 42
            }
            """
        let ast = try parse(source)
        #expect(ast == [.objectDeclaration(Object(
            name: "LifeTheUniverseAndEverything",
            staticFields: [Variable(name: "answer", semantics: .immutable, type: .builtin(.integer))],
        ))])
    }

    @Test
    func supertype() async throws {
        let source = """
            object Super {}
            object S: Super {}
            """
        let ast = try parse(source)
        #expect(ast.last == .objectDeclaration(Object(
            name: "S",
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
