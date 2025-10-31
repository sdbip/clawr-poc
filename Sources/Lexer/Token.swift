public struct Token: Equatable, Sendable {
    public let value: String
    public let kind: Kind
    public let location: TokenLocation

    public init(value: String, kind: Kind, location: TokenLocation) {
        self.value = value
        self.kind = kind
        self.location = location
    }

    public enum Kind: String, Sendable {
        case binary      = "BINARY"
        case decimal     = "DECIMAL"
        case punctuation = "PUNCTUATION"
        case keyword     = "KEYWORD"
        case identifier  = "IDENTIFIER"
        case builtinType = "BUILTIN"
    }
}

public struct TokenLocation: Equatable, Sendable {
    public var line: UInt
    public var column: UInt

    public init(line: UInt, column: UInt) {
        self.line = line
        self.column = column
    }
}
