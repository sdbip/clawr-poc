import Testing
import Lexer

@Suite("TokenStream")
struct TokenStreamTests {
    @Test("Keywords", arguments: [
        "let", "mut", "ref",
        "print",
        "data", "object", "service", "trait", "role",
        "factory", "static", "mutating", "operator",
    ])
    func keywords(_ keyword: String) async throws {
        let tokens = tokenize(keyword)
        #expect(tokens == [
            Token(value: keyword, kind: .keyword, location: FileLocation(line: 1, column: 1)),
        ])
    }

    @Test("Builtin types", arguments: ["integer", "bitfield", "real"])
    func primitive_types(_ type: String) async throws {
        let tokens = tokenize(type)
        #expect(tokens == [
            Token(value: type, kind: .builtinType, location: FileLocation(line: 1, column: 1)),
        ])
    }

    @Test("Unrestricted identifiers", arguments: ["x", "y", "entity"])
    func identifiers(_ identifier: String) async throws {
        let tokens = tokenize(identifier)
        #expect(tokens == [
            Token(value: identifier, kind: .identifier, location: FileLocation(line: 1, column: 1)),
        ])
    }

    @Test("Decimal numbers", arguments: ["12", "1_000_000", "9_223_372_036_854_775_807", "12.4"])
    func decimals(_ literal: String) async throws {
        let tokens = tokenize(literal)
        #expect(tokens == [
            Token(value: literal, kind: .decimal, location: FileLocation(line: 1, column: 1)),
        ])
    }

    @Test("Punctuation symbols", arguments: [":", "=>", "->"])
    func punctuation(_ symbol: String) async throws {
        let tokens = tokenize(symbol)
        #expect(tokens == [
            Token(value: symbol, kind: .punctuation, location: FileLocation(line: 1, column: 1)),
        ])
    }

    @Test("Operators", arguments: ["=", ">>", "<<"])
    func operators(_ symbol: String) async throws {
        let tokens = tokenize(symbol)
        #expect(tokens == [
            Token(value: symbol, kind: .operator, location: FileLocation(line: 1, column: 1)),
        ])
    }

    @Test("Complete variable declaration")
    func full_variable_declaration() async throws {
        let tokens = tokenize("let x: integer = 27")
        #expect(tokens == [
            Token(value: "let", kind: .keyword, location: FileLocation(line: 1, column: 1)),
            Token(value: "x", kind: .identifier, location: FileLocation(line: 1, column: 5)),
            Token(value: ":", kind: .punctuation, location: FileLocation(line: 1, column: 6)),
            Token(value: "integer", kind: .builtinType, location: FileLocation(line: 1, column: 8)),
            Token(value: "=", kind: .operator, location: FileLocation(line: 1, column: 16)),
            Token(value: "27", kind: .decimal, location: FileLocation(line: 1, column: 18)),
        ])
    }

    @Test("Collapsed newlines")
    func newlines() async throws {
        let tokens = tokenize("""
            let

            x:
            integer =
                27
            """)
        #expect(tokens == [
            Token(value: "let", kind: .keyword, location: FileLocation(line: 1, column: 1)),
            Token(value: "\n", kind: Lexer.Token.Kind.punctuation, location: Lexer.FileLocation(line: 1, column: 4)),
            Token(value: "x", kind: .identifier, location: FileLocation(line: 3, column: 1)),
            Token(value: ":", kind: .punctuation, location: FileLocation(line: 3, column: 2)),
            Token(value: "\n", kind: Lexer.Token.Kind.punctuation, location: Lexer.FileLocation(line: 3, column: 3)),
            Token(value: "integer", kind: .builtinType, location: FileLocation(line: 4, column: 1)),
            Token(value: "=", kind: .operator, location: FileLocation(line: 4, column: 9)),
            Token(value: "\n", kind: Lexer.Token.Kind.punctuation, location: Lexer.FileLocation(line: 4, column: 10)),
            Token(value: "27", kind: .decimal, location: FileLocation(line: 5, column: 5)),
        ])
    }

    @Test("C++-style comment is ignored")
    func cpp_comment() async throws {
        let tokens = tokenize("""
            let // ignored text
            x
            """)
        #expect(tokens == [
            Token(value: "let", kind: .keyword, location: FileLocation(line: 1, column: 1)),
            Token(value: "x", kind: .identifier, location: FileLocation(line: 2, column: 1)),
        ])

    }

    @Test("C-style comment is ignored")
    func c_comment() async throws {
        let tokens = tokenize("""
            let /* ignored
            text */ x
            """)
        #expect(tokens == [
            Token(value: "let", kind: .keyword, location: FileLocation(line: 1, column: 1)),
            Token(value: "x", kind: .identifier, location: FileLocation(line: 2, column: 9)),
        ])
    }

    @Test("Multiple comments on the same line")
    func multiple_comment() async throws {
        let tokens = tokenize("""
            let /* ignored
            text */ // x
            """)
        #expect(tokens == [
            Token(value: "let", kind: .keyword, location: FileLocation(line: 1, column: 1)),
        ])
    }

    private func tokenize(_ source: String) -> [Token] {
        let stream = TokenStream(source: source)
        return Array(stream)
    }
}

extension TokenStream: Sequence, IteratorProtocol {
    public func next() -> Token? { next(skippingNewlines: false) }
    public func makeIterator() -> TokenStream { return self }
}
