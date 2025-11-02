import Lexer

public func parse(_ source: String) throws -> [Statement] {
    let scope = Scope()
    let stream = TokenStream(source: source)
    return try parse(stream, in: scope)
}

func parse(_ stream: TokenStream, in scope: Scope) throws -> [Statement] {
    let parseables: [StatementParseable.Type] = [
        PrintStatement.self,
        VariableDeclaration.self,
        DataStructureDeclaration.self,
        FunctionDeclaration.self,
        FunctionCall.self,
    ]

    var result: [Statement] = []

    while stream.peek() != nil {
        if stream.peek()?.value == "}" { break }

        guard let type = parseables.first(where: { $0.isNext(in: stream) }) else { throw ParserError.invalidToken(try stream.peek().required()) }
        let unresolved = try type.init(parsing: stream, in: scope)
        result.append(try unresolved.resolve())
    }
    return result
}

public enum ParserError: Error {
    case unexpectedEOF
    case invalidToken(Token)
    case unresolvedType(FileLocation)
    case unknownVariable(String, FileLocation)
    case typeMismatch(declared: ResolvedType, inferred: ResolvedType, location: FileLocation)
}
