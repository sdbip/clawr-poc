import Lexer

struct FunctionDeclaration {
    var name: String
    var parameters: [Labeled<Variable>]
    var body: FunctionBody
    var returnType: String?
}

extension FunctionDeclaration: StatementParseable {
    static func isNext(in stream: TokenStream) -> Bool {
        guard let token = stream.peek() else { return false }
        return ["func", "pure"].contains(token.value)
    }

    init(parsing stream: TokenStream, in scope: Scope) throws {
        _ = try stream.next().requiring { $0.value == "func" }

        let name = try stream.next().requiring { $0.kind == .identifier }.value
        _ = try stream.next().requiring { $0.value == "(" }

        var parameters: [Labeled<Variable>] = []
        if stream.peek()?.value != ")" {
            while true {
                try parameters.append(parseParameter(stream: stream, in: scope))
                if stream.peek()?.value == ")" { break }
                _ = try stream.next()?.requiring { $0.value == "," }
            }
        }

        _ = try stream.next().requiring { $0.value == ")" }

        let returnType: String?
        if stream.peek()?.value == "->" {
            _ = stream.next()
            returnType = try stream.next().requiring { $0.kind == .identifier || $0.kind == .builtinType }.value
        } else {
            returnType = nil
        }

        let body: FunctionBody
        let scope = Scope(parent: scope, parameters: parameters.map {
            switch $0 {
            case .labeled(let variable, label: _),
                 .unlabeled(let variable):
                return variable
            }
        })

        if stream.peek()?.value == "=>" {
            _ = stream.next()
            body = try .implicitReturn(Expression.parse(stream: stream, in:scope).value)
        } else {
            _ = try stream.next().requiring { $0.value == "{" }
            body = try .multipleStatements(parse(stream, in: scope))
            _ = try stream.next().requiring { $0.value == "}" }
        }

        self.init(name: name, parameters: parameters, body: body, returnType: returnType)
    }

    func resolve() throws -> Statement {

        if case .implicitReturn(let returnExpression) = body {
            return try .functionDeclaration(
                name,
                returns: ResolvedType(resolving: returnType, expression: (returnExpression, FileLocation(line: 0, column: 0))),
                parameters: parameters,
                body: body
            )
        } else {
            return .functionDeclaration(
                name,
                returns: returnType.flatMap { ResolvedType(rawValue: $0) },
                parameters: parameters,
                body: body
            )

        }
    }
}

func parseParameter(stream: TokenStream, in scope: Scope) throws -> Labeled<Variable> {
    let nameToken = try stream.next().requiring { $0.kind == .identifier }
    let label = Located<String>(value: nameToken.value, location: nameToken.location)
    let name: String
    if stream.peek()?.kind == .identifier {
        name = try stream.next().required().value
    } else {
        name = label.value
    }

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

    let variable = Variable(
        name: name,
        semantics: .immutable,
        type: resolvedType
    )

    return label.value == "_"
        ? .unlabeled(variable)
        : .labeled(variable, label: label.value)
}
