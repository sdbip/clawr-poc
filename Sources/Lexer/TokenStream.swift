public class TokenStream {
    private let source: String
    private var location: Location

    public init(source: String) {
        self.source = source
        self.location = Location(source: source)
    }

    public func clone() -> TokenStream {
        let clone = TokenStream(source: source)
        clone.location = location
        return clone
    }

    public func peek(skippingNewlines: Bool = true) -> Token? {
        if location.isAtEnd { return nil }

        let clone = clone()
        return clone.next(skippingNewlines: skippingNewlines)
    }

    public func next(skippingNewlines: Bool = true) -> Token? {

        if skippingNewlines {
            while !location.isAtEnd && (location.currentCharacter.isNewline || location.currentCharacter.isWhitespace) { location.advance() }
        }

        skipComments(andNewlines: skippingNewlines)

        if location.isAtEnd { return nil }

        if location.currentCharacter.isNewline {
            defer {
                location.skip { $0.isNewline }
                location.skip(while: { $0.isWhitespace })
            }
            return Token(value: "\n", kind: .punctuation, location: location.location)
        }

        if punctuationGlyphs.contains(location.currentCharacter) {
            let p = punctuation.union(operators)
                .filter { location.matches(string: $0) }
                .sorted { $1.count < $0.count }
                .first!

            defer {
                location.advance(by: p.count)
                location.skip { $0.isWhitespace && !$0.isNewline }
            }

            return Token(
                value: p,
                kind: kind(for: p),
                location: location.location)
        }

        let isDecimal = location.currentCharacter.isWholeNumber
        var end = location
        end.skip { !$0.isWhitespace && ((isDecimal && $0 == ".") || !punctuationGlyphs.contains($0)) }

        defer {
            location = end
            location.skip { $0.isWhitespace && !$0.isNewline }
        }

        let value = location.stringValue(upto: end)
        return Token(value: value, kind: kind(for: value), location: location.location)
    }

    private struct Location {
        private let source: String
        private var index: String.Index
        private(set) var location: FileLocation

        var isAtEnd: Bool {
            index == source.endIndex
        }

        var currentCharacter: Character {
            return source[index]
        }

        init(source: String) {
            self.source = source
            self.index = source.startIndex
            self.location = FileLocation(line: 1, column: 1)
        }

        init(source: String, nextIndex: String.Index, location: FileLocation) {
            self.source = source
            self.index = nextIndex
            self.location = location
        }

        func matches(string: String) -> Bool {
            return source[index...].hasPrefix(string)
        }

        func stringValue(upto end: Location) -> String {
            return String(source[index..<end.index])
        }

        mutating func skip(while predicate: (Character) -> Bool) {
            while !isAtEnd && predicate(source[index]) {
                advance()
            }
        }

        mutating func advance() {
            if source[index].isNewline {
                location.line += 1
                location.column = 1
            } else {
                location.column += 1
            }
            index = source.index(after: index)
        }

        mutating func advance(by count: Int) {
            for _ in 0..<count { advance() }
        }

        func advanced() -> Location {
            return advanced(by: 1)
        }

        func advanced(by count: Int) -> Location {
            var other = self
            other.advance(by: count)
            return other
        }
    }

    private func skipComments(andNewlines skippingNewlines: Bool) {
        guard !location.isAtEnd else { return }
        guard location.currentCharacter == "/" else { return }

        let next = location.advanced(by: 1)
        if next.currentCharacter == "/" {
            location.skip { !$0.isNewline }
            if !location.isAtEnd { location.advance() }
        } else if next.currentCharacter == "*" {
            var end = next.advanced(by: 1)

            end.skip { $0 != "*" }
            end.advance(by: 2)
            end.skip { $0.isWhitespace && (skippingNewlines || !$0.isNewline) }

            location = end
            skipComments(andNewlines: skippingNewlines)
        }
    }
}

private let builtins = Set([
    "integer", "real", "boolean", "bitfield",
    "string", "regex",
])
private let keywords = Set([
    // Modeling
    "let", "mut", "ref", // variables
    "func", "pure", "operator", // functions / methods / operators
    "data", "enum", "object", "service", "role", "trait",  // types
    "bitstruct", "bitobject", // Single-register structures (functionally bitfield)
    "static", "mutating", "factory", // object modeling
    "abstract", "extendable", "virtual", // inheritance

    // Single keyword expressions
    "true", "false", "null", "self", "super",

    "print",

    // Control flow
    "return", "continue", "fallthrough", "break",
    "if", "else", "unless", "guard", "switch", "when", "case",
    "do", "while", "for", "in",
])

private let operators = Set([
    // Arithmetics
    "+", "-", "*", "/",

    // Comparisons
    "==", "===", "!=", "!==", "<", ">", ">=", "<=",

    // Boolean operators
    "&&", "||", "!",

    // Bitfield operators
    "&", "|", "^", "~",

    // Assignment
    "+=", "-=", "/=", "*=", "=",
    "|=", "&=", "^=", "<<", ">>", "<<=", ">>=",
])

private let punctuation = Set([

    ",", ".", "?", ":",
    "[", "]", "{", "}", "(", ")",

    // Functions
    "->", "=>",

    // Null-coalescing
    "!.", "?.", "??",
])

private let punctuationGlyphs = Set((punctuation.union(operators)).flatMap(\.self))

private func kind(for value: String) -> Token.Kind {
    if value.wholeMatch(of: /^\d+(_\d+)*(\.\d+(_\d+)*)?$/) != nil {
        .decimal
    } else if keywords.contains(value) {
        .keyword
    } else if builtins.contains(value) {
        .builtinType
    } else if operators.contains(value) {
        .operator
    } else if punctuation.contains(value) {
        .punctuation
    } else if value.hasPrefix("0x") || value.hasPrefix("0b") {
        .binary
    } else {
        .identifier
    }
}
