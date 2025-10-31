import Testing
import Parser

@Suite("Variable Declarations")
struct VariableDeclarationTests {

    @Test("Explicit integer")
    func explicit_integer() async throws {
        let source = "let x: integer = 2"
        let ast = try parse(source)
        #expect(ast == [
            .variableDeclaration("x", semantics: .immutable, type: "integer", initializer: .integer(2))
        ])
    }

    @Test("Inferred integer")
    func inferred_integer() async throws {
        let source = "let x = 2"
        let ast = try parse(source)
        #expect(ast == [
            .variableDeclaration("x", semantics: .immutable, type: "integer", initializer: .integer(2))
        ])
    }
}
