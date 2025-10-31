public enum Statement: Equatable {
    case variableDeclaration(String, semantics: Semantics, type: ResolvedType, initializer: Expression?)
}

public enum ResolvedType: String, Sendable {
    case boolean
    case integer
    case real
    case bitfield
    case string
    case regex
}
