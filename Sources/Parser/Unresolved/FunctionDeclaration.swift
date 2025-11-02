import Lexer

struct FunctionDeclaration {
    var name: Located<String>
    var parameters: [Labeled<VariableDeclaration>]
    var body: FunctionBody
    var returnType: Located<String>?
}

enum FunctionBody {
    case implicitReturn(UnresolvedExpression)
    case multipleStatements([UnresolvedStatement])
}

extension FunctionBody {
    func resolve(in scope: Scope, declaredReturnType: String?) throws -> (ResolvedType?, [Statement]) {
        switch self {
        case .implicitReturn(let expression):
            let resolvedExpression = try expression.resolve(in: scope)
            let resolvedReturnType = try ResolvedType(resolving: declaredReturnType, expression: (resolvedExpression, location: expression.location))
            return (resolvedReturnType, [.returnStatement(resolvedExpression)])
        case .multipleStatements(let statements):
            let resolvedReturnType = declaredReturnType.flatMap { BuiltinType(rawValue: $0) }.map { ResolvedType.builtin($0) }
            return (resolvedReturnType, try statements.map { try $0.resolve(in: scope) })
        }
    }
}

extension FunctionDeclaration: StatementParseable {
    static func isNext(in stream: TokenStream) -> Bool {
        guard let token = stream.peek() else { return false }
        return ["func", "pure"].contains(token.value)
    }

    var asStatement: UnresolvedStatement {
        return .functionDeclaration(name, returns: returnType, parameters: parameters, body: body)
    }

    init(parsing stream: TokenStream) throws {
        _ = try stream.next().requiring { $0.value == "func" }

        let nameToken = try stream.next().requiring { $0.kind == .identifier }
        _ = try stream.next().requiring { $0.value == "(" }

        var parameters: [Labeled<VariableDeclaration>] = []
        if stream.peek()?.value != ")" {
            while true {
                try parameters.append(parseParameter(stream: stream))
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
        if stream.peek()?.value == "=>" {
            _ = stream.next()
            body = try .implicitReturn(UnresolvedExpression.parse(stream: stream))
        } else {
            _ = try stream.next().requiring { $0.value == "{" }
            body = try .multipleStatements(parse(stream))
            _ = try stream.next().requiring { $0.value == "}" }
        }

        self.init(name: (nameToken.value, nameToken.location), parameters: parameters, body: body, returnType: returnType)
    }
}

func parseParameter(stream: TokenStream) throws -> Labeled<VariableDeclaration> {
    let clone = stream.clone()
    let labelToken = try clone.next().requiring { $0.kind == .identifier }
    if clone.next()?.kind == .identifier {
        _ = stream.next()
        let variable = try VariableDeclaration(parsing: stream, defaultSemantics: .immutable)
        return labelToken.value == "_"
            ? .unlabeled(variable)
            : .labeled(variable, label: labelToken.value)
    } else {
        let variable = try VariableDeclaration(parsing: stream, defaultSemantics: .immutable)
        return .labeled(variable, label: variable.name.value)
    }
}
