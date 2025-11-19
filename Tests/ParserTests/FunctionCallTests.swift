import Testing
import Lexer
@testable import Parser

@Suite("Function Calls")
struct FunctionCallTests {
    @Test(
        "Incomplete calls",
        arguments: ["f (", "f( 1 , 2"]
    )
    func unexpected_end(_ source: String) async throws {
        let stream = TokenStream(source: source)
        let error = try #require(throws: ParserError.self) { try FunctionCall(parsing: stream) }
        guard case .unexpectedEOF = error else {
            Issue.record("Did not throw the expected error, was: \(error)")
            return
        }
    }

    @Test(
        "Valid calls",
        arguments: [
            "foo()",
            "foo( )",
            "foo(  )",
            "foo(1)",
            "foo(1, 2)",
            "foo(1, 2, 3)",
            "foo(1,\n2,\n3)",
            "foo(1,\n 2,\n 3)",
        ]
    )
    func valid_function_calls(_ source: String) async throws {
        let stream = TokenStream(source: source)
        _ = try FunctionCall.init(parsing: stream)
    }

    @Test("Resolves top-level function")
    func resolves_toplevel() async throws {
        let source = """
            func f() {}
            f()
            """
        let ast = try parse(source)
        #expect(ast == [
            .functionDeclaration(Function(name: "f", isPure: false, returnType: nil, parameters: [], body: [])),
            .functionCall("f", arguments: []),
        ])
    }

    @Test("Method call as expression")
    func static_method_expression() async throws {
        let source = """
            data S { static: pure f() => 42 }
            print S.f()
            """
        let ast = try parse(source)
        guard case .printStatement(let expr) = ast.last else { Issue.record("Expected print statement, got: \(ast)"); return }
        guard case .methodCall(let function, target: .identifier(let target, type: let targetType), arguments: let arguments, type: let returnType) = expr else { Issue.record("Expected method call in print statement, got: \(expr)"); return }

        #expect(function == "f")
        #expect(target == "S")
        #expect(targetType == .companionObject(CompanionObject(
            name: "S_static",
            methods: [Function(name: "f", isPure: true, returnType: .builtin(.integer), parameters: [], body: [.returnStatement(.integer(42))])]
        )))
        #expect(arguments.isEmpty)
        #expect(returnType == .builtin(.integer))
    }

    @Test(
        "Resolves function name",
        arguments: [
            ("f(arg: 12)", "f(arg:)"),
            ("f()", "f()"),
            ("f(12)", "f(_:)"),
        ]
    )
    func resolved_name(source: String, expected: String) async throws {
        let stream = TokenStream(source: source)
        let function = try FunctionCall(parsing: stream)
        #expect(function.resolvedName == expected)
    }

    @Test("Fails to resolve unknown function")
    func fails_to_resolve() async throws {
        let source = "f()"
        let error = try #require(throws: ParserError.self) { try parse(source) }
        guard case .unknownFunction(_, _) = error else { Issue.record("Threw the wrong error: \(error)"); return }
    }

    @Test("Requires matching labels")
    func fails_to_resolve_different_labels() async throws {
        let source = """
            func f(label: integer) {}
            f(4)
            """
        let error = try #require(throws: ParserError.self) { try parse(source) }
        guard case .unknownFunction(_, _) = error else { Issue.record("Threw the wrong error: \(error)"); return }
    }
}
