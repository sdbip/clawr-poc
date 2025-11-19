import Testing
import Lexer
@testable import Parser

@Suite("Data Structure Fields")
struct DataStructureFieldTests {

    @Test("Lookup")
    func simple_reference() async throws {
        let source = """
            data X { value: integer }
            let x: X = {value: 0}
            let y = x.value
            """
        let yAssignment = try parse(source).last
        guard case  .variableDeclaration(let decl) = yAssignment else {
            Issue.record("Expected variable declaration: \(yAssignment)")
            return
        }
        #expect(decl.initialValue == .memberLookup(
            .identifier(
                "x",
                type: .data(.init(name: "X", fields: [
                    Variable(name: "value", semantics: .isolated, type: .builtin(.integer), initialValue: nil)
                ]))
            ),
            member: "value",
            type: .builtin(.integer)
        ))
    }

    @Test("Lookup inner")
    func inner_reference() async throws {
        let innie = DataStructure(name: "Innie", fields: [Variable(name: "value", semantics: .isolated, type: .builtin(.integer), initialValue: nil)])
        let outie = DataStructure(name: "Outie", fields: [Variable(name: "innie", semantics: .isolated, type: .data(innie), initialValue: nil)])

        let source = """
            data Innie { value: integer }
            data Outie { innie: Innie }
            let x: Outie = { innie: { value: 0 } }
            let y = x.innie.value
            """
        let yAssignment = try parse(source).last
        guard case  .variableDeclaration(let decl) = yAssignment else {
            Issue.record("Expected variable declaration: \(yAssignment)")
            return
        }
        #expect(decl.initialValue == .memberLookup(
            .memberLookup(
                .identifier("x", type: .data(outie)),
                member: "innie",
                type: .data(innie)
            ),
            member: "value",
            type: .builtin(.integer)
        ))
    }
}
