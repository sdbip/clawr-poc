import Lexer

struct ObjectDeclaration {
    var name: String
    var methods: [FunctionDeclaration]
    var fields: [VariableDeclaration]
}

extension ObjectDeclaration: StatementParseable {
    var asStatement: UnresolvedStatement {
        return .objectDeclaration(self)
    }

    static func isNext(in stream: TokenStream) -> Bool {
        return stream.peek()?.value == "object"
    }

    init(parsing stream: TokenStream) throws {
        _ = try stream.next().requiring { $0.value == "object" }
        let name = try stream.next().requiring { $0.kind == .identifier }.value
        self.init(name: name, methods: [], fields: [])

        _ = try stream.next().requiring { $0.value == "{" }

        while let t = stream.peek(), t.value != "data" && t.value != "}" {
            let method = try FunctionDeclaration(parsing: stream)
            methods.append(method)
        }

        if stream.peek()?.value == "data" {
            _ = stream.next()
            _ = try stream.next().requiring { $0.value == ":" }

            while stream.peek()?.value != "}" {
                try fields.append(VariableDeclaration(parsing: stream, defaultSemantics: .isolated))

                if stream.peek()?.value == "," {
                    _ = stream.next()
                } else if stream.peek(skippingNewlines: false)?.value == "\n" {
                    _ = stream.next(skippingNewlines: false)
                }
            }
        }
        _ = try stream.next().requiring { $0.value == "}" }
    }
}
