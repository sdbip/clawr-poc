import Lexer

struct DataStructureDeclaration {
    var name: Located<String>
    var fields: [VariableDeclaration]
}

extension DataStructureDeclaration: StatementParseable {
    static func isNext(in stream: TokenStream) -> Bool {
        return stream.peek()?.value == "data"
    }

    var asStatement: UnresolvedStatement {
        return .dataStructureDeclaration(self)
    }

    init(parsing stream: TokenStream) throws {
        _ = try stream.next().requiring { $0.value == "data" }
        let nameToken = try stream.next().requiring { $0.kind == .identifier }
        _ = try stream.next().requiring { $0.value == "{" }
        var fields: [VariableDeclaration] = []
        while stream.peek()?.value != "}" {
            try fields.append(VariableDeclaration(parsing: stream, defaultSemantics: .isolated))

            if stream.peek()?.value == "," {
                _ = stream.next()
            } else if stream.peek(skippingNewlines: false)?.value == "\n" {
                _ = stream.next(skippingNewlines: false)
            }
        }
        _ = try stream.next().requiring { $0.value == "}" }
        self.init(name: (nameToken.value, nameToken.location), fields: fields)
    }

    func resolveDataStructure(in scope: Scope) throws -> DataStructure {
        return DataStructure(
            name: name.value,
            fields: try fields.map { try $0.resolveVariable(in: scope) }
        )
    }
}
