public struct Token: Equatable, Sendable {
    public let value: String
    public let kind: Kind
    public let location: FileLocation

    public init(value: String, kind: Kind, location: FileLocation) {
        self.value = value
        self.kind = kind
        self.location = location
    }

    public enum Kind: String, Sendable {
        case binary      = "BINARY"
        case decimal     = "DECIMAL"
        case `operator`  = "OPERATOR"
        case punctuation = "PUNCTUATION"
        case keyword     = "KEYWORD"
        case identifier  = "IDENTIFIER"
        case builtinType = "BUILTIN"
    }
}
