import Testing
import Lexer
import Parser

@Suite("Variable Declarations")
struct VariableDeclarationTests {

    @Test("Explicit integer")
    func explicit_integer() async throws {
        let source = "let x: integer = 2"
        let ast = try parse(source)
        #expect(ast == [
            .variableDeclaration(Variable(name: "x", semantics: .immutable, type: .builtin(.integer)), initializer: .integer(2))
        ])
    }

    @Test("Inferred integer")
    func inferred_integer() async throws {
        let source = "let x = 2"
        let ast = try parse(source)
        #expect(ast == [
            .variableDeclaration(Variable(name: "x", semantics: .immutable, type: .builtin(.integer)), initializer: .integer(2))
        ])
    }

    @Test("Explicit real")
    func explicit_real() async throws {
        let source = "let x: real = 2"
        let ast = try parse(source)
        #expect(ast == [
            .variableDeclaration(Variable(name: "x", semantics: .immutable, type: .builtin(.real)), initializer: .integer(2))
        ])
    }

    @Test("Inferred real")
    func inferred_real() async throws {
        let source = "let x = 2.0"
        let ast = try parse(source)
        #expect(ast == [
            .variableDeclaration(Variable(name: "x", semantics: .immutable, type: .builtin(.real)), initializer: .real(2.0))
        ])
    }

    @Test("Explicit boolean")
    func explicit_boolean() async throws {
        let source = "let x: boolean = true"
        let ast = try parse(source)
        #expect(ast == [
            .variableDeclaration(Variable(name: "x", semantics: .immutable, type: .builtin(.boolean)), initializer: .boolean(true))
        ])
    }

    @Test("Inferred boolean")
    func inferred_boolean() async throws {
        let source = "let x = false"
        let ast = try parse(source)
        #expect(ast == [
            .variableDeclaration(Variable(name: "x", semantics: .immutable, type: .builtin(.boolean)), initializer: .boolean(false))
        ])
    }

    @Test("Explicit bitfield")
    func explicit_bitfield() async throws {
        let source = "let x: bitfield = 0x12"
        let ast = try parse(source)
        #expect(ast == [
            .variableDeclaration(Variable(name: "x", semantics: .immutable, type: .builtin(.bitfield)), initializer: .bitfield(0x12))
        ])
    }

    @Test("Inferred bitfield")
    func inferred_bitfield() async throws {
        let source = "let x = 0b1010"
        let ast = try parse(source)
        #expect(ast == [
            .variableDeclaration(Variable(name: "x", semantics: .immutable, type: .builtin(.bitfield)), initializer: .bitfield(0b1010))
        ])
    }

    @Test("Negated bitfield")
    func negated_bitfield() async throws {
        let source = "let x = ~0b1010"
        let ast = try parse(source)
        #expect(ast == [
            .variableDeclaration(Variable(name: "x", semantics: .immutable, type: .builtin(.bitfield)), initializer: .unaryOperation(operator: .bitfieldNegation, expression: .bitfield(0b1010)))
        ])
    }

    @Test("Left-shifted bitfield")
    func left_shifted_bitfield() async throws {
        let source = "let x = 0b1010 << 2"
        let ast = try parse(source)
        #expect(ast == [
            .variableDeclaration(Variable(name: "x", semantics: .immutable, type: .builtin(.bitfield)), initializer: .binaryOperation(left: .bitfield(0b1010), operator: .leftShift, right: .integer(2)))
        ])
    }

    @Test("Type mismatch")
    func type_mismatch() async throws {
        let error = try #require(throws: ParserError.self) { try parse("let x: integer = 2.0") }
        guard case .typeMismatch(declared: let declared, inferred: let resolved, location: let location) = error else { Issue.record(); return; }
        #expect(declared == "integer")
        #expect(resolved == "real")
        #expect(location == FileLocation(line: 1, column: 18))
    }
}
