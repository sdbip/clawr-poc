import Lexer

struct ObjectDeclaration {
    var name: Located<String>
    var pureMethods: [FunctionDeclaration] = []
    var mutatingMethods: [FunctionDeclaration] = []
    var fields: [VariableDeclaration] = []
    var staticMethods: [FunctionDeclaration] = []
    var staticFields: [VariableDeclaration] = []
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
        let nameToken = try stream.next().requiring { $0.kind == .identifier }
        self.init(name: (nameToken.value, location: nameToken.location))

        _ = try stream.next().requiring { $0.value == "{" }

        while let t = stream.peek(), t.value != "data" && t.value != "mutating" && t.value != "static" && t.value != "}" {
            let method = try FunctionDeclaration(parsing: stream)
            pureMethods.append(method)
        }

        if stream.peek()?.value == "mutating" {
            _ = stream.next()
            _ = try stream.next().requiring { $0.value == ":" }

            while let t = stream.peek(), t.value != "data" && t.value != "}" {
                let method = try FunctionDeclaration(parsing: stream)
                mutatingMethods.append(method)
            }
        }

        if stream.peek()?.value == "static" {
            _ = stream.next()
            _ = try stream.next().requiring { $0.value == ":" }

            while let t = stream.peek(), t.value != "data" && t.value != "}" {
                if FunctionDeclaration.isNext(in: stream) {
                    try staticMethods.append(FunctionDeclaration(parsing: stream))
                } else if VariableDeclaration.isNext(in: stream) {
                    try staticFields.append(VariableDeclaration(parsing: stream))
                } else {
                    throw ParserError.invalidToken(t)
                }
            }
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

    func resolveObject(in scope: Scope) throws -> Object {
        return Object(
            name: name.value,
            pureMethods: try pureMethods.map { try $0.resolveFunction(in: scope) },
            mutatingMethods: try mutatingMethods.map { try $0.resolveFunction(in: scope) },
            fields: try fields.map { try $0.resolveVariable(in: scope) },
            staticMethods: try staticMethods.map { try $0.resolveFunction(in: scope) },
            staticFields: try staticFields.map { try $0.resolveVariable(in: scope) },
        )
    }
}
