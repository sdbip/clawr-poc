import Lexer

public func parse(_ source: String) throws -> [Statement] {
    let stream = TokenStream(source: source)
    return try parse(stream)
}

func parse(_ stream: TokenStream) throws -> [Statement] {
    var result: [Statement] = []

    while stream.peek() != nil {
        if stream.peek()?.value == "}" { break }

        if PrintStatement.isNext(in: stream) {
            let unresolved = try PrintStatement(parsing: stream)
            result.append(.printStatement(unresolved.expression))
        } else if VariableDeclaration.isNext(in: stream) {
            let unresolved = try VariableDeclaration(parsing: stream)
            try result.append(unresolved.resolve())
        } else if FunctionDeclaration.isNext(in: stream) {
            let unresolved = try FunctionDeclaration(parsing: stream)
            try result.append(unresolved.resolve())
        } else {
            throw ParserError.invalidToken(try stream.peek().required())
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
