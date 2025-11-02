import Testing
import Lexer
@testable import Parser

@Suite("Data Structure Declarations")
struct DataStructureDeclarationTests {
    @Test(arguments: ["data", "data S", "data S {"])
    func unexpected_end(_ source: String) async throws {
        let error = try #require(throws: ParserError.self) { try parse(source) }
        guard case .unexpectedEOF = error else {
            Issue.record("Did not throw the expected error, was: \(error)")
            return
        }
    }

    @Test(arguments: ["data 12 {}", "data S 1"])
    func invalid_token(_ source: String) async throws {
        let error = try #require(throws: ParserError.self) { try parse(source)}
        guard case .invalidToken = error else {
            Issue.record("Did not throw the expected error, was: \(error)")
            return
        }
    }

    @Test
    func empty_data() async throws {
        let ast = try parse("data S {}")
        #expect(ast == [.dataStructureDeclaration("S", fields: [])])
    }

    @Test
    func single_field() async throws {
        let ast = try parse("data S { x: integer }")
        #expect(ast == [.dataStructureDeclaration(
            "S",
            fields: [Variable(
                name: "x",
                semantics: .isolated,
                type: .integer
            )]
        )])
    }

    @Test
    func multiple_fields() async throws {
        let ast = try parse("data S { x: integer, y: bitfield }")
        #expect(ast == [.dataStructureDeclaration(
            "S",
            fields: [
                Variable(name: "x", semantics: .isolated, type: .integer),
                Variable(name: "y", semantics: .isolated, type: .bitfield),
            ]
        )])
    }

    @Test
    func multiple_fields_with_newlines() async throws {
        let source = """
            data S {
                x: integer
                y: bitfield
            }
            """
        let ast = try parse(source)
        #expect(ast == [.dataStructureDeclaration(
            "S",
            fields: [
                Variable(
                    name: "x",
                    semantics: .isolated,
                    type: .integer
                ),
                Variable(
                    name: "y",
                    semantics: .isolated,
                    type: .bitfield
                ),
            ]
        )])
    }

    @Test
    func multiple_fields_with_trailing_commas() async throws {
        let source = """
            data S {
                x: integer,
                y: bitfield,
            }
            """
        let ast = try parse(source)
        #expect(ast == [.dataStructureDeclaration(
            "S",
            fields: [
                Variable(
                    name: "x",
                    semantics: .isolated,
                    type: .integer
                ),
                Variable(
                    name: "y",
                    semantics: .isolated,
                    type: .bitfield
                ),
            ]
        )])
    }

    @Test
    func multiple_fields_with_oddly_placed_commas() async throws {
        let source = """
            data S {
                x: integer
                ,
                y: bitfield
                ,
            }
            """
        let ast = try parse(source)
        #expect(ast == [.dataStructureDeclaration(
            "S",
            fields: [
                Variable(
                    name: "x",
                    semantics: .isolated,
                    type: .integer
                ),
                Variable(
                    name: "y",
                    semantics: .isolated,
                    type: .bitfield
                ),
            ]
        )])
    }
}
