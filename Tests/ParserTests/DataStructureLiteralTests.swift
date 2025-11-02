import Testing
import Lexer
@testable import Parser

@Suite("tata Structure Literals")
struct DataStructureLiteralTests {
    @Test
    func empty_struct() async throws {
        let source = "{}"
        let literal = try parseLiteral(source)
        #expect(literal.fieldValues.count == 0)
    }

    @Test
    func single_variable() async throws {
        let source = "{ value: 123 }"
        let literal = try parseLiteral(source)
        #expect(literal == DataStructureLiteral(fieldValues: [
            "value": .integer(123, location: FileLocation(line: 1, column: 10))
        ]))
    }

    @Test
    func multiple_variables_separated_by_comma() async throws {
        let source = "{ value1: 123, value2: 321 }"
        let literal = try parseLiteral(source)
        #expect(literal == DataStructureLiteral(fieldValues: [
            "value1": .integer(123, location: FileLocation(line: 1, column: 11)),
            "value2": .integer(321, location: FileLocation(line: 1, column: 24)),
        ]))
    }

    @Test
    func multiple_variables_separated_by_cnewline() async throws {
        let source = """
            {
                value1: 123
                value2: 321
            }
            """
        let literal = try parseLiteral(source)
        #expect(literal == DataStructureLiteral(fieldValues: [
            "value1": .integer(123, location: FileLocation(line: 2, column: 13)),
            "value2": .integer(321, location: FileLocation(line: 3, column: 13)),
        ]))
    }
}

private func parseLiteral(_ source: String) throws -> DataStructureLiteral {
    let stream = TokenStream(source: source)
    return try DataStructureLiteral.parse(stream: stream)
}
