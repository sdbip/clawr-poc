import Lexer

struct DataStructureDeclaration {
    var name: Located<String>
    var fields: [VariableDeclaration]
    var staticSection: StaticSection?
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
        var staticSection: StaticSection? = nil

        while let t = stream.peek(), t.value != "}" && t.value != "static" {
            try fields.append(VariableDeclaration(parsing: stream, defaultSemantics: .isolated))

            if stream.peek()?.value == "," {
                _ = stream.next()
            } else if stream.peek(skippingNewlines: false)?.value == "\n" {
                _ = stream.next(skippingNewlines: false)
            }
        }

        if stream.peek()?.value == "static" {
            while let t = stream.peek(), t.value != "}" {
                _ = stream.next()
                _ = try stream.next().requiring { $0.value == ":" }

                var fields: [VariableDeclaration] = []
                var methods: [FunctionDeclaration] = []
                while let t = stream.peek(), !sectionEnders.contains(t.value)  {
                    if FunctionDeclaration.isNext(in: stream) {
                        try methods.append(FunctionDeclaration(parsing: stream))
                    } else if VariableDeclaration.isNext(in: stream) {
                        try fields.append(VariableDeclaration(parsing: stream))
                    } else {
                        throw ParserError.invalidToken(t)
                    }
                }
                staticSection = StaticSection(fields: fields, methods: methods)
            }
        }
        _ = try stream.next().requiring { $0.value == "}" }
        self.init(name: (nameToken.value, nameToken.location), fields: fields, staticSection: staticSection)
    }

    func resolveDataStructure(in scope: Scope) throws -> DataStructure {
        return DataStructure(
            name: name.value,
            fields: try fields.map { try $0.resolveVariable(in: scope) },
            companion: try staticSection.map {
                try CompanionObject(
                    name: "\(name.value).static",
                    fields: $0.fields.map { try $0.resolveVariable(in: scope) },
                    methods: $0.methods.map { try $0.resolveFunction(in: scope) },
                )
            }
        )
    }
}
