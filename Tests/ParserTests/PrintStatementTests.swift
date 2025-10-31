import Testing
import Lexer
@testable import Parser

@Suite("Print Statement")
struct PrintStatementTests {
    @Test("Integer input")
    func integer_input() async throws {
        let declarations = try parse("print 123")
        #expect(declarations == [.printStatement(.integer(123))])
    }

    @Test("Real input")
    func real_input() async throws {
        let declarations = try parse("print 12.3")
        #expect(declarations == [.printStatement(.real(12.3))])
    }

    @Test("Bitfield input")
    func bitfield_input() async throws {
        let declarations = try parse("print 0xa123")
        #expect(declarations == [.printStatement(.bitfield(0xa123))])
    }

    @Test("Boolean input")
    func boolean_input() async throws {
        let declarations = try parse("print true")
        #expect(declarations == [.printStatement(.boolean(true))])
    }
}
