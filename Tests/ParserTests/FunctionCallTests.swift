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
        let error = try #require(throws: ParserError.self) { try parse(source) }
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
        _ = try parse(source)
    }
}
