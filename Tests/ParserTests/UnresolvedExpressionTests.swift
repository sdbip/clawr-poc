import Testing
import Lexer
@testable import Parser

@Suite("Unresolved Expressions")
struct UnresolvedExpressionTests {
    @Test("Integer literal with underscore")
    func integer_with_grouping() async throws {
        let stream = TokenStream(source: "1_2_3")
        let expr = try UnresolvedExpression.parse(stream: stream)
        guard case .integer(let value, _) = expr else { Issue.record(); return }
        #expect(value == 123)
    }

    @Test("Real literal with underscore")
    func real_with_grouping() async throws {
        let stream = TokenStream(source: "1_2.3")
        let expr = try UnresolvedExpression.parse(stream: stream)
        guard case .real(let value, _) = expr else { Issue.record(); return }
        #expect(value == 12.3)
    }

    @Test("HEX Bitfield literal with underscore")
    func hex_bitfield_with_grouping() async throws {
        let stream = TokenStream(source: "0x1_2_3")
        let expr = try UnresolvedExpression.parse(stream: stream)
        guard case .bitfield(let value, _) = expr else { Issue.record(); return }
        #expect(value == 0x123)
    }

    @Test("BIN Bitfield literal with underscore")
    func binary_bitfield_with_grouping() async throws {
        let stream = TokenStream(source: "0b1_1_0")
        let expr = try UnresolvedExpression.parse(stream: stream)
        guard case .bitfield(let value, _) = expr else { Issue.record(); return }
        #expect(value == 0b110)
    }

    @Test("Right-shifted bitfield")
    func right_shifted_bitfield() async throws {
        let source = "0b1010 >> 2"
        let stream = TokenStream(source: source)
        let expr = try UnresolvedExpression.parse(stream: stream)
        guard case .binaryOperation(left: .bitfield(let bitfield, _), operator: let op, right: .integer(let i, _), _) = expr else { Issue.record("Unexpected expression: \(expr)"); return }
        #expect(bitfield == 0b1010)
        #expect(op == .rightShift)
        #expect(i == 2)
    }

    @Test("Addition")
    func addition() async throws {
        let source = "let x = 1 + 2"
        let ast = try parse(source)
        guard case .variableDeclaration(_, initializer: let expr) = ast.first else { Issue.record("Unexpected expression: \(ast)"); return }
        #expect(expr == .binaryOperation(left: .integer(1), operator: .addition, right: .integer(2)))
    }

    @Test("Multiplication")
    func multiplication() async throws {
        let source = "let x = 2 * 3"
        let ast = try parse(source)
        guard case .variableDeclaration(_, initializer: let expr) = ast.first else { Issue.record("Unexpected expression: \(ast)"); return }
        #expect(expr == .binaryOperation(left: .integer(2), operator: .multiplication, right: .integer(3)))
    }

    @Test("Multiple operators are evaluated left-to-right")
    func multiple_additions() async throws {
        let source = "let x = 1 + 2 - 3"
        let ast = try parse(source)
        guard case .variableDeclaration(_, initializer: let expr) = ast.first else { Issue.record("Unexpected expression: \(ast)"); return }
        #expect(expr == .binaryOperation(left: .binaryOperation(left: .integer(1), operator: .addition, right: .integer(2)), operator: .subtraction, right: .integer(3)))
    }

    @Test("Addition has lower precedence than multiplication")
    func precedence() async throws {
        let source = "let x = 1 + 2 * 3"
        let ast = try parse(source)
        guard case .variableDeclaration(_, initializer: let expr) = ast.first else { Issue.record("Unexpected expression: \(ast)"); return }
        #expect(expr == .binaryOperation(left: .integer(1), operator: .addition, right: .binaryOperation(left: .integer(2), operator: .multiplication, right: .integer(3))))
    }
}
