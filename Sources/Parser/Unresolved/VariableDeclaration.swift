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
            let typeToken = try stream.next().requiring { $0.kind == .builtinType || $0.kind == .identifier }
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
        guard let type = try scope.resolveType(name: type, initializer: initializer) else { throw ParserError.unresolvedType(name.location) }
        return Variable(
            name: name.value,
            semantics: semantics.value,
            type: type
        )
    }
}

extension Scope {
    func resolveType(name: Located<String>?, initializer: UnresolvedExpression?) throws -> ResolvedType? {
        let resolvedType = resolve(typeNamed: name)
        let resolvedInitializer = try initializer?.resolve(in: self, declaredType: name?.value)

        switch (resolvedType, resolvedInitializer) {
        case (.some(let type), .none): return type
        case (.builtin(.real), .integer(_)): return .builtin(.real)
        case (nil, .some(let e)): return e.type
        case (.some(let type), .some(let e)) where e.type == type: return type
        case (.some(let type), .some(let e)):
            throw ParserError.typeMismatch(declared: type.name, inferred: e.type.name, location: initializer!.location)
        case (nil, nil):
            return nil
        }
    }
}
