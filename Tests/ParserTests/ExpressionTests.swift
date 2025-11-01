import Testing
import Lexer
@testable import Parser

@Suite("Expressions")
struct ExpressionTests {
    @Test("Integer literal with underscore")
    func integer_with_grouping() async throws {
        let stream = TokenStream(source: "1_2_3")
        let expr = try Expression.parse(stream: stream, in: Scope())
        guard case .integer(let value) = expr.value else { Issue.record(); return }
        #expect(value == 123)
    }

    @Test("Real literal with underscore")
    func real_with_grouping() async throws {
        let stream = TokenStream(source: "1_2.3")
        let expr = try Expression.parse(stream: stream, in: Scope())
        guard case .real(let value) = expr.value else { Issue.record(); return }
        #expect(value == 12.3)
    }

    @Test("HEX Bitfield literal with underscore")
    func hex_bitfield_with_grouping() async throws {
        let stream = TokenStream(source: "0x1_2_3")
        let expr = try Expression.parse(stream: stream, in: Scope())
        guard case .bitfield(let value) = expr.value else { Issue.record(); return }
        #expect(value == 0x123)
    }

    @Test("BIN Bitfield literal with underscore")
    func binary_bitfield_with_grouping() async throws {
        let stream = TokenStream(source: "0b1_1_0")
        let expr = try Expression.parse(stream: stream, in: Scope())
        guard case .bitfield(let value) = expr.value else { Issue.record(); return }
        #expect(value == 0b110)
    }
}
