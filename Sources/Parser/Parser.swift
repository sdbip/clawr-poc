import Lexer

public func parse(_ source: String) throws -> [Statement] {
    let stream = TokenStream(source: source)
    let unresolved = try VariableDeclaration.parse(stream: stream)
    guard let resolvedType = unresolved.type.flatMap(ResolvedType.init(rawValue:)) ?? unresolved.initializer?.type else { throw ParserError.unresolvedType }

    switch (resolvedType, unresolved.initializer?.type) {
    case (_, nil): break
    case (.real, .integer): break
    case (let a, let b) where a == b: break
    case (let a, .some(let b)):
        throw ParserError.typeMismatch(declared: a, inferred: b)
    }

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
    case typeMismatch(declared: ResolvedType, inferred: ResolvedType)
}
