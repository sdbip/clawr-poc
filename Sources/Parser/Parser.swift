import Lexer

public func parse(_ source: String) throws -> [Statement] {
    let stream = TokenStream(source: source)
    let keywordToken = try stream.next().requiring { $0.kind == .keyword }
    guard let semantics = Semantics(rawValue: keywordToken.value) else { throw ParserError.invalidToken(keywordToken) }
    let name = try stream.next().requiring { $0.kind == .identifier }.value
    _ = try stream.next().requiring { $0.value == ":" }
    let type = try stream.next().requiring { $0.kind == .builtinType }.value
    _ = try stream.next().requiring { $0.value == "=" }
    let initializer = try stream.next().requiring { $0.kind == .decimal }.value

    return [
        .variableDeclaration(name, semantics: semantics, type: type, initializer: .integer(Int64(initializer)!))
    ]
}

public enum ParserError: Error {
    case unexpectedEOF
    case invalidToken(Token)
}
