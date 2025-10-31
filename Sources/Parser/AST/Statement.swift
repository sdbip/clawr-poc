public enum Statement: Equatable {
    case variableDeclaration(String, semantics: Semantics, type: String, initializer: Expression)
}
