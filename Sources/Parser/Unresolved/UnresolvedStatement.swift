enum UnresolvedStatement {
    case variableDeclaration(VariableDeclaration)
    case functionDeclaration(FunctionDeclaration)
    case functionCall(Located<String>, arguments: [Labeled<UnresolvedExpression>])
    case dataStructureDeclaration(Located<String>, fields: [VariableDeclaration])
    case printStatement(UnresolvedExpression)
    case returnStatement(UnresolvedExpression)
}

extension UnresolvedStatement {
    func resolve(in scope: Scope) throws -> Statement {
        switch self {

        case .variableDeclaration(let decl):
            let variable = try decl.resolveVariable(in: scope)
            scope.register(variable: variable)
            return try .variableDeclaration(variable, initializer: decl.initializer?.resolve(in: scope, declaredType: decl.type?.value))

        case .functionDeclaration(let decl):
            let function = try decl.resolveFunction(in: scope)
            scope.register(function: function)
            return .functionDeclaration(function)

        case .functionCall(let name, arguments: let arguments):
            let resolvedName = Function.resolvedName(base: name.value, labels: arguments.map { $0.label })
            guard let function = scope.function(forName: resolvedName) else { throw ParserError.unknownFunction(resolvedName, name.location) }
            return try .functionCall(name.value, arguments: arguments.map {
                // TODO: Match arguments to parameters
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
