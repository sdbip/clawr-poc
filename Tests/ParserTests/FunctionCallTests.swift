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

    @Test("Resolves")
    func resolves() async throws {
        let source = """
            func f() {}
            f()
            """
        let ast = try parse(source)
        #expect(ast == [
            .functionDeclaration(Function(name: "f", returnType: nil, parameters: [], body: [])),
            .functionCall("f", arguments: []),
        ])
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
            func f(lsbel: integer) {}
            f(4)
            """
        let error = try #require(throws: ParserError.self) { try parse(source) }
        guard case .unknownFunction(_, _) = error else { Issue.record("Threw the wrong error: \(error)"); return }
    }
}
