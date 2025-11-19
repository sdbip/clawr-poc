import Lexer

struct FunctionDeclaration {
    var name: Located<String>
    var isPure: Bool
    var parameters: [Labeled<VariableDeclaration>]
    var body: FunctionBody
    var returnType: Located<String>?
}

enum FunctionBody {
    case implicitReturn(UnresolvedExpression)
    case multipleStatements([UnresolvedStatement])
}

extension FunctionDeclaration: StatementParseable {
    static func isNext(in stream: TokenStream) -> Bool {
        guard let token = stream.peek() else { return false }
        return ["func", "pure"].contains(token.value)
    }

    var asStatement: UnresolvedStatement {
        return .functionDeclaration(self)
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

        self.init(name: (nameToken.value, nameToken.location), isPure: false, parameters: parameters, body: body, returnType: returnType)
    }

    func resolveFunction(in scope: Scope) throws -> Function {
        let parameters = try parameters.map {
            return try $0.map { try $0.resolveVariable(in: scope) }
        }
        let bodyScope = Scope(parent: scope, parameters: parameters.map(\.value))
        let (resolvedReturnType, bodyStatements) = try resolveBody()

        return Function(
            name: name.value,
            isPure: isPure,
            returnType: resolvedReturnType,
            parameters: parameters,
            body: bodyStatements
        )

        func resolveBody() throws -> (ResolvedType?, [Statement]) {
            switch body {
            case .implicitReturn(let expression):
                let resolvedExpression = try expression.resolve(in: bodyScope, declaredType: returnType?.value)
                let resolvedReturnType = try bodyScope.resolveType(name: returnType.map { ($0.value, location: $0.location) }, initializer: expression)
                guard let resolvedReturnType else { throw ParserError.unresolvedType(name.location) }
                return (resolvedReturnType, [.returnStatement(resolvedExpression)])
            case .multipleStatements(let statements):
                let resolvedReturnType = returnType.flatMap { BuiltinType(rawValue: $0.value) }.map { ResolvedType.builtin($0) }
                return (resolvedReturnType, try statements.map { try $0.resolve(in: bodyScope) })
            }
        }
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
