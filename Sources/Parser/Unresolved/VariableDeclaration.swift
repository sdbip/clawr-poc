import Lexer

struct VariableDeclaration {
    var name: Located<String>
    var semantics: Located<Semantics>
    var type: Located<String>?
    var initializer: UnresolvedExpression?
}

extension VariableDeclaration: StatementParseable {
    static func isNext(in stream: TokenStream) -> Bool {
        guard let token = stream.peek() else { return false }
        return Semantics(rawValue: token.value) != nil
    }

    var asStatement: UnresolvedStatement {
        return .variableDeclaration(self)
    }

    init(parsing stream: TokenStream) throws {
        try self.init(parsing: stream, defaultSemantics: nil)
    }

    init(parsing stream: TokenStream, defaultSemantics: Semantics?) throws {
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
        let initializer: UnresolvedExpression?

        if stream.peek()?.value == "=" {
            _ = try stream.next().requiring { $0.value == "=" }
            initializer = try UnresolvedExpression.parse(stream: stream)
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

    func resolveVariable(in scope: Scope) throws -> Variable {
        let resolvedType: ResolvedType?
        if let initializer {
            resolvedType = try ResolvedType(resolving: type?.value, expression: (value: initializer.resolve(in: scope), location: initializer.location))
        } else if let type = type?.value {
            resolvedType = BuiltinType(rawValue: type).map { .builtin($0) }
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
