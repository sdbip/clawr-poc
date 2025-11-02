import Lexer

struct DataStructureDeclaration {
    public var name: String
    public var fields: [VariableDeclaration]

    public init(name: String, fields: [VariableDeclaration]) {
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
        var fields: [VariableDeclaration] = []
        while stream.peek()?.value != "}" {
            try fields.append(VariableDeclaration(parsing: stream, defaultSemantics: .isolated, in: scope))

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
        return try .dataStructureDeclaration(name, fields: fields.map { try $0.resolveVariable() })
    }
}
