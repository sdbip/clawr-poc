import Lexer

public func parse(_ source: String) throws -> [Statement] {
    let stream = TokenStream(source: source)

    if stream.peek()?.value == "print" {
        let unresolved = try PrintStatement.parse(stream: stream)
        return [.printStatement(unresolved.expression)]
    } else {

        let unresolved = try VariableDeclaration.parse(stream: stream)
        guard let resolvedType = unresolved.type.map({ ResolvedType(rawValue: $0.value) }) ?? unresolved.initializer?.value.type else { throw ParserError.unresolvedType(unresolved.name.location) }

        switch (resolvedType, unresolved.initializer) {
        case (_, nil): break
        case (.real, let declared) where declared?.value.type == .integer: break
        case (let a, let b) where a == b?.value.type: break
        case (let a, .some(let b)):
            throw ParserError.typeMismatch(declared: a, inferred: b.value.type, location: b.location)
        }

        return [.variableDeclaration(
            unresolved.name.value,
            semantics: unresolved.semantics.value,
            type: resolvedType,
            initializer: unresolved.initializer?.value
        )]
    }
}

public enum ParserError: Error {
    case unexpectedEOF
    case invalidToken(Token)
    case unresolvedType(FileLocation)
    case typeMismatch(declared: ResolvedType, inferred: ResolvedType, location: FileLocation)
}
