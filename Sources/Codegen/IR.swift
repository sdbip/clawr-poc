public enum Statement {
    case structDeclaration(String, fields: any Sequence<Field>)
    case variable(String, type: String, initializer: Expression)
    case assign(Reference, value: Expression)
    case function(String, returns: String, parameters: [Field], body: [Statement])
    case call(Reference, arguments: [Expression])
    case `return`(Expression)
}

public indirect enum Expression {
    case cast(Expression, type: String)
    case literal(String)
    case reference(Reference)
    case call(Reference, arguments: [Expression])
    case structInitializer([NamedValue])
    case arrayInitializer([Expression])
}

public indirect enum Reference {
    case address(of: Reference)
    case name(String)
    case field(target: Expression, name: String, isPointer: Bool)
}

public struct NamedValue {
    public var name: String
    public var value: Expression

    public init(name: String, value: Expression) {
        self.name = name
        self.value = value
    }
}

public struct Trait {
    public var name: String
    public var methods: [String]

    public init(name: String, methods: [String]) {
        self.name = name
        self.methods = methods
    }
}

public struct Function {
    public var name: String
    public var returnType: String
    public var parameters: [Field]

    public init(name: String, returnType: String, parameters: [Field]) {
        self.name = name
        self.returnType = returnType
        self.parameters = parameters
    }
}

public struct Field {
    public var type: Type
    public var name: String

    public init(type: Type, name: String) {
        self.type = type
        self.name = name
    }
}

public enum Type {
    case simple(String)
    case function(returnType: String, parameters: any Sequence<String>)
}
