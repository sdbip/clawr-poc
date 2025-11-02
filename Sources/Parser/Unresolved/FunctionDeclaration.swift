import Lexer

struct FunctionDeclaration {
    var name: String
    var parameters: [Labeled<VariableDeclaration>]
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

        var parameters: [Labeled<VariableDeclaration>] = []
        if stream.peek()?.value != ")" {
            while true {
                try parameters.append(parseParameter(stream: stream, in: scope))
                if stream.peek()?.value == ")" { break }
                _ = try stream.next().requiring { $0.value == "," }
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
        let scope = try Scope(parent: scope, parameters: parameters.map {
            switch $0 {
            case .labeled(let variable, label: _),
                 .unlabeled(let variable):
                return try variable.resolveVariable()
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
                parameters: parameters.map(resolveParameter(_:)),
                body: body
            )
        } else {
            return try .functionDeclaration(
                name,
                returns: returnType.flatMap { ResolvedType(rawValue: $0) },
                parameters: parameters.map(resolveParameter(_:)),
                body: body
            )

        }
    }

    func resolveParameter(_ variable: Labeled<VariableDeclaration>) throws -> Labeled<Variable> {
        switch variable {
        case .labeled(let v, label: let l): try .labeled(v.resolveVariable(), label: l)
        case .unlabeled(let v): try .unlabeled(v.resolveVariable())
        }
    }
}

func parseParameter(stream: TokenStream, in scope: Scope) throws -> Labeled<VariableDeclaration> {
    let clone = stream.clone()
    let labelToken = try clone.next().requiring { $0.kind == .identifier }
    if clone.next()?.kind == .identifier {
        _ = stream.next()
        let variable = try VariableDeclaration(parsing: stream, defaultSemantics: .immutable, in: scope)
        return labelToken.value == "_"
            ? .unlabeled(variable)
            : .labeled(variable, label: labelToken.value)
    } else {
        let variable = try VariableDeclaration(parsing: stream, defaultSemantics: .immutable, in: scope)
        return .labeled(variable, label: variable.name.value)
    }
}
