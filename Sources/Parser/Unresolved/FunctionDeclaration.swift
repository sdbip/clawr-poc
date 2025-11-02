import Lexer

struct FunctionDeclaration {
    var name: Located<String>
    var parameters: [Labeled<VariableDeclaration>]
    var body: FunctionBody
    var returnType: Located<String>?
}

enum FunctionBody {
    case implicitReturn(UnresolvedExpression)
    case multipleStatements([Statement])
}

extension FunctionDeclaration: StatementParseable {
    static func isNext(in stream: TokenStream) -> Bool {
        guard let token = stream.peek() else { return false }
        return ["func", "pure"].contains(token.value)
    }

    init(parsing stream: TokenStream, in scope: Scope) throws {
        _ = try stream.next().requiring { $0.value == "func" }

        let nameToken = try stream.next().requiring { $0.kind == .identifier }
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

        let returnTypeToken: Token?
        if stream.peek()?.value == "->" {
            _ = stream.next()
            returnTypeToken = try stream.next().requiring { $0.kind == .identifier || $0.kind == .builtinType }
        } else {
            returnTypeToken = nil
        }
        let returnType = returnTypeToken.map { ($0.value, $0.location) }

        let body: FunctionBody
        let scope = try Scope(parent: scope, parameters: parameters.map {
            switch $0 {
            case .labeled(let variable, label: _),
                 .unlabeled(let variable):
                return try variable.resolveVariable(in: scope)
            }
        })

        if stream.peek()?.value == "=>" {
            _ = stream.next()
            body = try .implicitReturn(UnresolvedExpression.parse(stream: stream))
        } else {
            _ = try stream.next().requiring { $0.value == "{" }
            body = try .multipleStatements(parse(stream, in: scope))
            _ = try stream.next().requiring { $0.value == "}" }
        }

        self.init(name: (nameToken.value, nameToken.location), parameters: parameters, body: body, returnType: returnType)
    }

    func resolve(in scope: Scope) throws -> Statement {

        let parameters = try parameters.map { try resolveParameter($0, in: scope) }
        let bodyScope = Scope(parent: scope, parameters: parameters.map { $0.value })

        switch body {
        case .implicitReturn(let returnExpression):
            return try .functionDeclaration(
                name.value,
                returns: ResolvedType(resolving: returnType?.value, expression: (value: returnExpression.resolve(in: bodyScope), location: returnExpression.location)),
                parameters: parameters,
                body: [.returnStatement(returnExpression.resolve(in: bodyScope))]
            )
        case .multipleStatements(let statements):
            return try .functionDeclaration(
                name.value,
                returns: returnType.flatMap { ResolvedType(rawValue: $0.value) },
                parameters: parameters,
                body: statements
            )
        }
    }

    func resolveParameter(_ variable: Labeled<VariableDeclaration>, in scope: Scope) throws -> Labeled<Variable> {
        switch variable {
        case .labeled(let v, label: let l): try .labeled(v.resolveVariable(in: scope), label: l)
        case .unlabeled(let v): try .unlabeled(v.resolveVariable(in: scope))
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
