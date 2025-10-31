import Lexer

public func parse(_ source: String) throws -> [Statement] {
    let stream = TokenStream(source: source)
    var result: [Statement] = []

    while stream.peek() != nil {
        if stream.peek()?.value == "print" {
            let unresolved = try PrintStatement(parsing: stream)
            result.append(.printStatement(unresolved.expression))
        } else {
            let unresolved = try VariableDeclaration(parsing: stream)
            guard let resolvedType = unresolved.type.map({ ResolvedType(rawValue: $0.value) }) ?? unresolved.initializer?.value.type else { throw ParserError.unresolvedType(unresolved.name.location) }

            switch (resolvedType, unresolved.initializer) {
            case (_, nil): break
            case (.real, let declared) where declared?.value.type == .integer: break
            case (let a, let b) where a == b?.value.type: break
            case (let a, .some(let b)):
                throw ParserError.typeMismatch(declared: a, inferred: b.value.type, location: b.location)
            }

            result.append(.variableDeclaration(
                unresolved.name.value,
                semantics: unresolved.semantics.value,
                type: resolvedType,
                initializer: unresolved.initializer?.value
            ))
        }
    }
    return result
}

public enum ParserError: Error {
    case unexpectedEOF
    case invalidToken(Token)
    case unresolvedType(FileLocation)
    case typeMismatch(declared: ResolvedType, inferred: ResolvedType, location: FileLocation)
}
