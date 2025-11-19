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
        #expect(ast == [.dataStructureDeclaration(DataStructure(name: "S", fields: []))])
    }

    @Test("Can be used as variable type")
    func variable_declaration() async throws {
        _ = try parse("data S {} let x: S")
    }

    @Test
    func single_field() async throws {
        let ast = try parse("data S { x: integer }")
        #expect(ast == [.dataStructureDeclaration(DataStructure(
            name: "S",
            fields: [Variable(
                name: "x",
                semantics: .isolated,
                type: .builtin(.integer),
                initialValue: nil
            )]
        ))])
    }

    @Test
    func multiple_fields() async throws {
        let ast = try parse("data S { x: integer, y: bitfield }")
        #expect(ast == [.dataStructureDeclaration(DataStructure(
            name: "S",
            fields: [
                Variable(name: "x", semantics: .isolated, type: .builtin(.integer), initialValue: nil),
                Variable(name: "y", semantics: .isolated, type: .builtin(.bitfield), initialValue: nil),
            ]
        ))])
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
        #expect(ast == [.dataStructureDeclaration(DataStructure(
            name: "S",
            fields: [
                Variable(
                    name: "x",
                    semantics: .isolated,
                    type: .builtin(.integer)
                ),
                Variable(
                    name: "y",
                    semantics: .isolated,
                    type: .builtin(.bitfield)
                ),
            ]
        ))])
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
        #expect(ast == [.dataStructureDeclaration(DataStructure(
            name: "S",
            fields: [
                Variable(
                    name: "x",
                    semantics: .isolated,
                    type: .builtin(.integer)
                ),
                Variable(
                    name: "y",
                    semantics: .isolated,
                    type: .builtin(.bitfield)
                ),
            ]
        ))])
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
        #expect(ast == [.dataStructureDeclaration(DataStructure(
            name: "S",
            fields: [
                Variable(
                    name: "x",
                    semantics: .isolated,
                    type: .builtin(.integer)
                ),
                Variable(
                    name: "y",
                    semantics: .isolated,
                    type: .builtin(.bitfield)
                ),
            ]
        ))])
    }

    @Test
    func static_field() async throws {
        let ast = try parse("data S { static: let x = 43 }")
        #expect(ast == [.dataStructureDeclaration(DataStructure(
            name: "S",
            fields: [],
            companion: CompanionObject(name: "S_static", fields: [
                Variable(name: "x", semantics: .immutable, type: .builtin(.integer), initialValue: .integer(43)),
            ])
        ))])
    }

    @Test
    func static_field_lookup() async throws {
        let source = """
            data S { static: let answer = 42 }
            let a = S.answer
            """
        let ast = try parse(source)
        guard case .variableDeclaration(let variable) = ast.last else { Issue.record("Expected a variable declaration from \(ast)"); return }
        guard case .memberLookup(.identifier(let identifier, type: let identifierType), member: let member, _) = variable.initialValue else { Issue.record("Expected member-lookup from \(variable.initialValue)"); return }
        guard case .companionObject(let data) = identifierType else { Issue.record("Expected companion-object reference, was: \(identifierType)"); return }
        #expect(variable.type == .builtin(.integer))
        #expect(identifier == "S")
        #expect(data.name == "S_static")
        #expect(member == "answer")
    }
}
