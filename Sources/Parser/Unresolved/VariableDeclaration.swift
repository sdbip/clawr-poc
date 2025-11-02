import Lexer

struct VariableDeclaration {
    var name: Located<String>
    var semantics: Located<Semantics>
    var type: Located<String>?
    var initializer: Located<Expression>?
}

extension VariableDeclaration: StatementParseable {
    static func isNext(in stream: TokenStream) -> Bool {
        guard let token = stream.peek() else { return false }
        return Semantics(rawValue: token.value) != nil
    }

    init(parsing stream: TokenStream, in scope: Scope) throws {
        try self.init(parsing: stream, defaultSemantics: nil, in: scope)
    }

    init(parsing stream: TokenStream, defaultSemantics: Semantics?, in scope: Scope) throws {
        let keywordToken: Token = try stream.next().required()
        guard let semantics = Semantics(rawValue: keywordToken.value) ?? defaultSemantics else { throw ParserError.invalidToken(keywordToken) }
        let nameToken = keywordToken.kind == .identifier ? keywordToken : try stream.next().requiring { $0.kind == .identifier }
        let name = Located<String>(value: nameToken.value, location: nameToken.location)
        let type: Located<String>?
        if stream.peek()?.value == ":" {
            _ = try stream.next().requiring { $0.value == ":" }
            let typeToken = try stream.next().requiring { $0.kind == .builtinType }
            type = (value: typeToken.value, location: typeToken.location)
        } else {
            type = nil
        }
        let initializer: Located<Expression>?

        if stream.peek()?.value == "=" {
            _ = try stream.next().requiring { $0.value == "=" }
            initializer = try Expression.parse(stream: stream, in: scope)
        } else {
            initializer = nil
        }

        self.init(
            name: name,
            semantics: (value: semantics, location: keywordToken.location),
            type: type,
            initializer: initializer
        )
    }

    func resolve() throws -> Statement {
        return try .variableDeclaration(
            resolveVariable(),
            initializer: initializer?.value
        )
    }

    func resolveVariable() throws -> Variable {
        let resolvedType: ResolvedType?
        if let initializer {
            resolvedType = try ResolvedType(resolving: type?.value, expression: initializer)
        } else if let type = type?.value {
            resolvedType = ResolvedType(rawValue: type)
        } else {
            resolvedType = nil
        }

        guard let resolvedType else { throw ParserError.unresolvedType(name.location) }
        return Variable(
            name: name.value,
            semantics: semantics.value,
            type: resolvedType
        )
    }
}
