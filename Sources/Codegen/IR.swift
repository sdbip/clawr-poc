public enum IR {
    case data(name: String, fields: any Sequence<Field>)
}

public struct Field {
    public var type: String
    public var name: String

    public init(type: String, name: String) {
        self.type = type
        self.name = name
    }
}
