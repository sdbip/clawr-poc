public enum Statement: Equatable {
    case variableDeclaration(Variable, initializer: Expression?)
    case functionDeclaration(Function)
    case functionCall(String, arguments: [Labeled<Expression>])
    case dataStructureDeclaration(DataStructure)
    case objectDeclaration(Object)
    case printStatement(Expression)
    case returnStatement(Expression)
}

public enum ResolvedType: Equatable {
    case builtin(BuiltinType)
    case data(DataStructure)
    case object(Object)
    case companionObject(CompanionObject)

    public var name: String {
        switch self {
        case .builtin(let t): t.rawValue
        case .data(let d): d.name
        case .object(let o): o.name
        case .companionObject(let o): o.name
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
    public var companion: CompanionObject?

    public init(name: String, fields: [Variable], companion: CompanionObject? = nil) {
        self.name = name
        self.fields = fields
        self.companion = companion
    }
}

public struct Object: Equatable {
    public var name: String
    public var isAbstract: Bool
    public var supertype: Indirect<ResolvedType>?
    public var pureMethods: [Function]
    public var mutatingMethods: [Function]
    public var fields: [Variable]
    public var factoryMethods: [Function]
    public var staticMethods: [Function]
    public var staticFields: [Variable]

    public init(
            name: String,
            isAbstract: Bool = false,
            supertype: ResolvedType? = nil,
            pureMethods: [Function] = [],
            mutatingMethods: [Function] = [],
            fields: [Variable] = [],
            factoryMethods: [Function] = [],
            staticMethods: [Function] = [],
            staticFields: [Variable] = [],
            ) {
        self.name = name
        self.isAbstract = isAbstract
        self.supertype = supertype.map { .value($0) }
        self.pureMethods = pureMethods
        self.mutatingMethods = mutatingMethods
        self.fields = fields
        self.factoryMethods = factoryMethods
        self.staticMethods = staticMethods
        self.staticFields = staticFields
    }
}

public struct CompanionObject: Equatable {
    public var name: String
    public var fields: [Variable]
    public var methods: [Function]

    public init(name: String, fields: [Variable] = [], methods: [Function] = []) {
        self.name = name
        self.fields = fields
        self.methods = methods
    }
}
