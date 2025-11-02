import Lexer

struct DataStructureDeclaration {
    var name: Located<String>
    var fields: [VariableDeclaration]
}

extension DataStructureDeclaration: StatementParseable {
    static func isNext(in stream: TokenStream) -> Bool {
        return stream.peek()?.value == "data"
    }

    init(parsing stream: TokenStream, in scope: Scope) throws {
        _ = try stream.next().requiring { $0.value == "data" }
        let nameToken = try stream.next().requiring { $0.kind == .identifier }
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
        self.init(name: (nameToken.value, nameToken.location), fields: fields)
    }

    func resolve(in scope: Scope) throws -> Statement {
        return try .dataStructureDeclaration(name.value, fields: fields.map { try $0.resolveVariable(in: scope) })
    }
}
