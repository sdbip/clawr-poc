import Lexer

public struct DataStructureDeclaration: Equatable {
    public var name: String
    public var fields: [Variable]

    public init(name: String, fields: [Variable]) {
        self.name = name
        self.fields = fields
    }
}

extension DataStructureDeclaration: StatementParseable {
    static func isNext(in stream: TokenStream) -> Bool {
        return stream.peek()?.value == "data"
    }

    init(parsing stream: TokenStream, in scope: Scope) throws {
        _ = try stream.next().requiring { $0.value == "data" }
        let name = try stream.next().requiring { $0.kind == .identifier }.value
        _ = try stream.next().requiring { $0.value == "{" }
        var fields: [Variable] = []
        while stream.peek()?.value != "}" {
            try fields.append(parseField(stream: stream, in: scope))

            if stream.peek()?.value == "," {
                _ = stream.next()
            } else if stream.peek(skippingNewlines: false)?.value == "\n" {
                _ = stream.next(skippingNewlines: false)
            }
        }
        _ = try stream.next().requiring { $0.value == "}" }
        self.init(name: name, fields: fields)
    }

    func resolve() throws -> Statement {
        return .dataStructureDeclaration(name, fields: fields)
    }
}

func parseField(stream: TokenStream, in scope: Scope) throws -> Variable {
    let nameToken = try stream.next().requiring { $0.kind == .identifier }
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

    let resolvedType: ResolvedType;
    if let initializer {
        resolvedType = try ResolvedType(resolving: type?.value, expression: initializer)
    } else if let type = type.flatMap({ ResolvedType(rawValue: $0.value) }) {
        resolvedType = type
    } else {
        throw ParserError.unresolvedType(nameToken.location)
    }

    return Variable(
        name: name.value,
        semantics: .isolated,
        type: resolvedType
    )
}
