import Lexer

struct VariableDeclaration {
    var name: String
    var semantics: Semantics
    var type: String?
    var initializer: Expression?
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
        let initializer: Expression?

        if stream.peek()?.value == "=" {
            _ = try stream.next().requiring { $0.value == "=" }
            let initializerToken = try stream.next().requiring { $0.kind == .decimal }

            if initializerToken.value.contains(".") {
                initializer = .real(Double(initializerToken.value)!)
            } else {
                initializer = .integer(Int64(initializerToken.value)!)
            }
        } else {
            initializer = nil
        }

        return VariableDeclaration(
            name: name,
            semantics: semantics,
            type: type,
            initializer: initializer
        )
    }
}
