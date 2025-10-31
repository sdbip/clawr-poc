import Lexer

struct VariableDeclaration {
    var name: String
    var semantics: Semantics
    var type: String?
    var initializer: Expression
}

extension VariableDeclaration {
    static func parse(stream: TokenStream) throws -> VariableDeclaration {
        let keywordToken = try stream.next().requiring { $0.kind == .keyword }
        guard let semantics = Semantics(rawValue: keywordToken.value) else { throw ParserError.invalidToken(keywordToken) }
        let name = try stream.next().requiring { $0.kind == .identifier }.value
        let type: String?
        if stream.peek()?.value == ":" {
            _ = try stream.next().requiring { $0.value == ":" }
            type = try stream.next().requiring { $0.kind == .builtinType }.value
        } else {
            type = nil
        }
        _ = try stream.next().requiring { $0.value == "=" }
        let initializer = try stream.next().requiring { $0.kind == .decimal }.value

        return VariableDeclaration(
            name: name,
            semantics: semantics,
            type: type,
            initializer: .integer(Int64(initializer)!)
        )
    }
}
