public enum Statement: Equatable {
    case variableDeclaration(Variable, initializer: Expression?)
    case functionDeclaration(String, returns: ResolvedType?, parameters: [Labeled<Variable>], body: [Statement])
    case functionCall(String, arguments: [Labeled<Expression>])
    case dataStructureDeclaration(String, fields: [Variable])
    case printStatement(Expression)
    case returnStatement(Expression)
}

public enum ResolvedType: Equatable, Sendable {
    case builtin(BuiltinType)
}

public enum BuiltinType: String, Sendable {
    case boolean
    case integer
    case real
    case bitfield
    case string
    case regex
}

public struct Variable: Equatable {
    public var name: String
    public var semantics: Semantics
    public var type: ResolvedType

    public init(name: String, semantics: Semantics, type: ResolvedType) {
        self.name = name
        self.semantics = semantics
        self.type = type
    }
}

extension ResolvedType {
    init(resolving string: String?, expression: Located<Expression>) throws {
        let resolved = string.flatMap { BuiltinType(rawValue:$0) }
        switch (resolved, expression) {
        case (.real, (.integer(_), _)):
            self = .builtin(.real)

        case (.some(let type), (let e, _)) where e.type == .builtin(type):
            self = .builtin(type)

        case (.some(let t), (let e, let location)):
            throw ParserError.typeMismatch(declared: .builtin(t), inferred: e.type, location: location)

        case (nil, (let e, _)):
            self = e.type
        }
    }
}
