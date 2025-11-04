public enum Statement: Equatable {
    case variableDeclaration(Variable, initializer: Expression?)
    case functionDeclaration(Function)
    case functionCall(String, arguments: [Labeled<Expression>])
    case dataStructureDeclaration(DataStructure)
    case printStatement(Expression)
    case returnStatement(Expression)
}

public enum ResolvedType: Equatable {
    case builtin(BuiltinType)
    case data(DataStructure)

    public var name: String {
        switch self {
        case .builtin(let t): t.rawValue
        case .data(let d): d.name
        }
    }
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

public struct Function: Equatable {
    public var name: String
    public var returnType: ResolvedType?
    public var parameters: [Labeled<Variable>]
    public var body: [Statement]

    var resolutionName: String {
        return Self.resolvedName(base: name, labels: parameters.map { $0.label })
    }

    public init(name: String, returnType: ResolvedType?, parameters: [Labeled<Variable>], body: [Statement]) {
        self.name = name
        self.returnType = returnType
        self.parameters = parameters
        self.body = body
    }

    static func resolvedName(base: String, labels: [String?]) -> String {
        return "\(base)(\(labels.map { "\($0 ?? "_"):"}.joined(separator: ",")))"
    }
}

public struct DataStructure: Equatable {
    public var name: String
    public var fields: [Variable]

    public init(name: String, fields: [Variable]) {
        self.name = name
        self.fields = fields
    }
}
