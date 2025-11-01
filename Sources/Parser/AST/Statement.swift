public enum Statement: Equatable {
    case variableDeclaration(Variable, initializer: Expression?)
    case functionDeclaration(String, returns: ResolvedType?, parameters: [Labeled<Variable>], body: FunctionBody)
    case functionCall(String, arguments: [Labeled<Expression>])
    case printStatement(Expression)
}

public enum ResolvedType: String, Sendable {
    case boolean
    case integer
    case real
    case bitfield
    case string
    case regex
}

public enum FunctionBody: Equatable {
    case implicitReturn(Expression)
    case multipleStatements([Statement])
}

public enum Labeled<T: Equatable>: Equatable {
    case unlabeled(T)
    case labeled(T, label: String)

    public var label: String? {
        switch self {
        case .unlabeled(_): nil
        case .labeled(_, label: let l): l
        }
    }

    public var value: T {
        switch self {
        case .labeled(let value, label: _),
             .unlabeled(let value): value
        }
    }
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
