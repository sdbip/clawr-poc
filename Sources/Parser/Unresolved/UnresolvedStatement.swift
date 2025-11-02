enum UnresolvedStatement {
    case variableDeclaration(VariableDeclaration)
    case functionDeclaration(Located<String>, returns: Located<String>?, parameters: [Labeled<VariableDeclaration>], body: FunctionBody)
    case functionCall(Located<String>, arguments: [Labeled<UnresolvedExpression>])
    case dataStructureDeclaration(Located<String>, fields: [VariableDeclaration])
    case printStatement(UnresolvedExpression)
    case returnStatement(UnresolvedExpression)
}

extension UnresolvedStatement {
    func resolve(in scope: Scope) throws -> Statement {
        switch self {

        case .variableDeclaration(let decl):
            // TODO: register Variable
            return try .variableDeclaration(decl.resolveVariable(in: scope), initializer: decl.initializer?.resolve(in: scope, declaredType: decl.type?.value))

        case .functionDeclaration(let name, returns: let returnType, parameters: let parameters, body: let body):
            let parameters = try parameters.map {
                return try $0.map { try $0.resolveVariable(in: scope) }
            }
            let bodyScope = Scope(parent: scope, parameters: parameters.map(\.value))
            let (resolvedReturnType, bodyStatements) = try resolveBody()

            return try .functionDeclaration(
                name.value,
                returns: resolvedReturnType,
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

        case .functionCall(let name, arguments: let arguments):
            return try .functionCall(name.value, arguments: arguments.map {
                // TODO: Look up the called function and match arguments to parameters
                return try $0.map { try $0.resolve(in: scope, declaredType: nil) }
            })

        case .dataStructureDeclaration(let name, fields: let fields):
            let data = DataStructure(name: name.value, fields: try fields.map { try $0.resolveVariable(in: scope) })
            scope.register(type: data)
            return .dataStructureDeclaration(
                data.name,
                fields: data.fields
            )

        case .printStatement(let expression):
            return try .printStatement(expression.resolve(in: scope, declaredType: nil))

        case .returnStatement(let expression):
            return try .returnStatement(expression.resolve(in: scope, declaredType: nil))
        }
    }
}
