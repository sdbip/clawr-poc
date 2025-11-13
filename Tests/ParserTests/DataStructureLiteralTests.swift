import Testing
import Lexer
@testable import Parser

@Suite("Data Structure Literals")
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
        #expect(literal.fieldValues.count == 1)
        guard case .integer(let value, _) = literal.fieldValues["value"] else {
            Issue.record("Failed to extract integer value from literal.")
            return
        }
        #expect(value == 123)
    }

    @Test
    func multiple_variables_separated_by_comma() async throws {
        let source = "{ value1: 123, value2: 321 }"
        let literal = try parseLiteral(source)
        #expect(literal.fieldValues.count == 2)
        guard case .integer(let value1, _) = literal.fieldValues["value1"] else {
            Issue.record("Failed to extract first integer value from literal.")
            return
        }
        guard case .integer(let value2, _) = literal.fieldValues["value2"] else {
            Issue.record("Failed to extract second integer value from literal.")
            return
        }
        #expect(value1 == 123)
        #expect(value2 == 321)
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
        #expect(literal.fieldValues.count == 2)
        guard case .integer(let value1, _) = literal.fieldValues["value1"] else {
            Issue.record("Failed to extract first integer value from literal.")
            return
        }
        guard case .integer(let value2, _) = literal.fieldValues["value2"] else {
            Issue.record("Failed to extract second integer value from literal.")
            return
        }
        #expect(value1 == 123)
        #expect(value2 == 321)
    }
}

private func parseLiteral(_ source: String) throws -> DataStructureLiteral {
    let stream = TokenStream(source: source)
    return try DataStructureLiteral.parse(stream: stream)
}
