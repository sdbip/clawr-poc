public enum Statement: Equatable {
    case variableDeclaration(Variable, initializer: Expression?)
    case functionDeclaration(String, returns: ResolvedType?, parameters: [Labeled<Variable>], body: [Statement])
    case functionCall(String, arguments: [Labeled<Expression>])
    case dataStructureDeclaration(String, fields: [Variable])
    case printStatement(Expression)
    case returnStatement(Expression)
}

public enum ResolvedType: String, Sendable {
    case boolean
    case integer
    case real
    case bitfield
    case string
    case regex
}

public enum Labeled<Value> {
    case unlabeled(Value)
    case labeled(Value, label: String)

    public var label: String? {
        switch self {
        case .unlabeled(_): nil
        case .labeled(_, label: let label): label
        }
    }

    public var value: Value {
        switch self {
        case .labeled(let value, label: _),
             .unlabeled(let value): value
        }
    }
}

extension Labeled: Equatable where Value: Equatable {}

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
        let resolved = string.flatMap { ResolvedType(rawValue:$0) }
        switch (resolved, expression) {
        case (.real, (.integer(_), _)):
            self = .real

        case (.some(let type), (let e, _)) where e.type == type:
            self = type

        case (.some(let t), (let e, let location)):
            throw ParserError.typeMismatch(declared: t, inferred: e.type, location: location)

        case (.none, (let e, _)):
            self = e.type
        }
    }
}
