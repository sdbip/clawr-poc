public enum Statement: Equatable {
    case variableDeclaration(Variable)
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
    public var initialValue: Expression?

    public init(name: String, semantics: Semantics, type: ResolvedType, initialValue: Expression? = nil) {
        self.name = name
        self.semantics = semantics
        self.type = type
        self.initialValue = initialValue
    }
}

public struct Function: Equatable {
    public var name: String
    public var isPure: Bool
    public var returnType: ResolvedType?
    public var parameters: [Labeled<Variable>]
    public var body: [Statement]

    var resolutionName: String {
        return Self.resolvedName(base: name, labels: parameters.map { $0.label })
    }

    public init(name: String, isPure: Bool, returnType: ResolvedType?, parameters: [Labeled<Variable>], body: [Statement]) {
        self.name = name
        self.isPure = isPure
        self.returnType = returnType
        self.parameters = parameters
        self.body = body
    }

    static func resolvedName(base: String, labels: [String?]) -> String {
        return "\(base)(\(labels.map { "\($0 ?? "_"):"}.joined(separator: ",")))"
    }
}

public class DataStructure {
    public var name: String
    public var fields: [Variable]
    public var companion: CompanionObject?

    public init(name: String, fields: [Variable], companion: CompanionObject? = nil) {
        self.name = name
        self.fields = fields
        self.companion = companion
    }
}

extension DataStructure: Equatable {
    public static func == (lhs: DataStructure, rhs: DataStructure) -> Bool {
        return lhs.name == rhs.name &&
            lhs.fields == rhs.fields &&
            lhs.companion == rhs.companion
    }
}

public class Object {
    public var name: String
    public var methods: [Function]
    public var fields: [Variable]
    public var factoryMethods: [Function]
    public var companion: CompanionObject?

    public init(
            name: String,
            methods: [Function] = [],
            fields: [Variable] = [],
            factoryMethods: [Function] = [],
            companion: CompanionObject? = nil,
            ) {
        self.name = name
        self.methods = methods
        self.fields = fields
        self.factoryMethods = factoryMethods
        self.companion = companion
    }
}

extension Object: Equatable {
    public static func == (lhs: Object, rhs: Object) -> Bool {
        return lhs.name == rhs.name &&
            lhs.methods == rhs.methods &&
            lhs.fields == rhs.fields &&
            lhs.factoryMethods == rhs.factoryMethods &&
            lhs.companion == rhs.companion
    }
}

public class CompanionObject {
    public var name: String
    public var fields: [Variable]
    public var methods: [Function]

    public init(name: String, fields: [Variable] = [], methods: [Function] = []) {
        self.name = name
        self.fields = fields
        self.methods = methods
    }
}

extension CompanionObject: Equatable {
    public static func == (lhs: CompanionObject, rhs: CompanionObject) -> Bool {
        return lhs.name == rhs.name &&
			lhs.fields == rhs.fields &&
        	lhs.methods == rhs.methods
    }
}
