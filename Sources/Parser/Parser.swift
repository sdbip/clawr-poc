import Lexer

public func parse(_ source: String) throws -> [Statement] {
    let stream = TokenStream(source: source)
    let unresolved = try VariableDeclaration.parse(stream: stream)
    guard let resolvedType = unresolved.type ?? unresolved.initializer?.type else { throw ParserError.unresolvedType }
    return [Statement.variableDeclaration(
        unresolved.name,
        semantics: unresolved.semantics,
        type: resolvedType,
        initializer: unresolved.initializer
    )]
}

public enum ParserError: Error {
    case unexpectedEOF
    case invalidToken(Token)
    case unresolvedType
}
