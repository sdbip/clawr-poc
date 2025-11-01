import Testing

import Lexer
@testable import Parser
@Suite("Function Declarations")
struct FunctionDeclarationTests {
    @Test("Incomplete declarations",
        arguments: ["func", "func f", "func f(", "func f() {", "func f() ->", "func f() =>"]
    )
    func unexpected_end(_ source: String) async throws {
        let error = try #require(throws: ParserError.self) { try parse(source) }
        guard case .unexpectedEOF = error else {
            Issue.record("Did not throw the expected error, was: \(error)")
            return
        }
    }

    @Test("Invalid tokens",
        arguments: ["func 12()", "func f 1)", "func f(1"]
    )
    func invalid_token(_ source: String) async throws {
        let error = try #require(throws: ParserError.self) { try parse(source)}
        guard case .invalidToken = error else {
            Issue.record("Did not throw the expected error, was: \(error)")
            return
        }
    }

    @Test("Empty declaration")
    func no_parameters_no_body() async throws {
        let ast = try parse("func f() {}")
        #expect(ast == [.functionDeclaration(
            "f",
            returns: nil,
            parameters: [],
            body: .multipleStatements([])
        )])
    }
    @Test("Declared return type")
    func return_type() async throws {
        let ast = try parse("func f() -> integer {}")
        #expect(ast == [.functionDeclaration(
            "f",
            returns: .integer,
            parameters: [],
            body: .multipleStatements([])
        )])
    }

    @Test("Simple parameter with default label")
    func single_parameter_no_body() async throws {
        let ast = try parse("func f(x: integer) {}")
        #expect(ast == [.functionDeclaration(
            "f",
            returns: nil,
            parameters: [.labeled(
                Variable(
                    name: "x",
                    semantics: .immutable,
                    type: .integer
                ),
                label: "x"
            )],
            body: .multipleStatements([])
        )])
    }

    @Test("Parameter with label and different internal name")
    func named_parameter() async throws {
        let ast = try parse("func f(x y: integer) {}")
        #expect(ast == [.functionDeclaration(
            "f",
            returns: nil,
            parameters: [.labeled(
                Variable(
                    name: "y",
                    semantics: .immutable,
                    type: .integer
                ),
                label: "x"
            )],
            body: .multipleStatements([])
        )])
    }

    @Test("Simple parameter without label")
    func unlabeled_parameter() async throws {
        let ast = try parse("func f(_ x: integer) {}")
        #expect(ast == [.functionDeclaration(
            "f",
            returns: nil,
            parameters: [.unlabeled(
                Variable(
                    name: "x",
                    semantics: .immutable,
                    type: .integer
                ),
            )],
            body: .multipleStatements([])
        )])
    }

    @Test("Multiple parameters")
    func multiple_parameters_no_body() async throws {
        let ast = try parse("func f(x: integer, y: bitfield) {}")
        #expect(ast == [.functionDeclaration(
            "f",
            returns: nil,
            parameters: [
                .labeled(
                    Variable(
                        name: "x",
                        semantics: .immutable,
                        type: .integer
                    ),
                    label: "x"
                ),
                .labeled(
                    Variable(
                        name: "y",
                        semantics: .immutable,
                        type: .bitfield
                    ),
                    label: "y"
                ),
            ],
            body: .multipleStatements([])
        )])
    }

    @Test("Code-block body")
    func body_no_parameters() async throws {
        let source = """
            func f() {
                let x: integer = 1
            }
            """
        let ast = try parse(source)
        #expect(ast == [.functionDeclaration(
            "f",
            returns: nil,
            parameters: [],
            body: .multipleStatements([
                .variableDeclaration(
                    Variable(
                        name: "x",
                        semantics: .immutable,
                        type: .integer),
                    initializer: .integer(1)
                )
            ])
        )])
    }

    @Test("Simple returned expression")
    func implicit_return() async throws {
        let source = "func f() => 1"
        let ast = try parse(source)
        #expect(ast == [.functionDeclaration(
            "f",
            returns: .integer,
            parameters: [],
            body: .implicitReturn(.integer(1))
        )])
    }

    @Test("Return an expression that references a parameter")
    func return_parameter_value() async throws {
        let source = "func identity(x: integer) => x"
        let ast = try parse(source)
        #expect(ast == [.functionDeclaration(
            "identity",
            returns: .integer,
            parameters: [.labeled(
                Variable(
                    name: "x",
                    semantics: .immutable,
                    type: .integer
                ),
                label: "x"
            )],
            body: .implicitReturn(.identifier("x", type: .integer))
        )])
    }

    @Test("Return an expression that references an unknown variable")
    func return_unknown_variable() async throws {
        let source = "func identity() => x"
        let error = try #require(throws: ParserError.self) { try parse(source) }
        guard case .unknownVariable(let name, let location) = error else { Issue.record("Wrong error thrown; was: \(error)"); return }
        #expect(name == "x")
        #expect(location == FileLocation(line: 1, column: 20))
    }
}
