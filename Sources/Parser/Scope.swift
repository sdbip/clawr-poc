public class Scope {
    private let parent: Scope?

    private var variables: [String : Variable] = [:]
    private var functions: [String : Function] = [:]
    private var types: [String : ResolvedType] = [:]

    public init() {
        self.parent = nil
    }

    public init(parent: Scope, parameters: [Variable]) {
        self.parent = parent
        for p in parameters {
            register(variable: p)
        }
    }

    public func variable(forName name: String) -> Variable? {
        return variables[name] ?? parent?.variable(forName: name)
    }

    public func register(variable: Variable) {
        variables[variable.name] = variable
    }

    public func register(function: Function) {
        functions[function.resolutionName] = function
    }

    public func function(forName name: String) -> Function? {
        return functions[name] ?? parent?.function(forName: name)
    }

    public func type(forName name: String) -> ResolvedType? {
        return types[name] ?? parent?.type(forName: name)
    }

    public func register(type: DataStructure) {
        types[type.name] = .data(type)
    }

    public func register(type: Object) {
        types[type.name] = .object(type)
    }

    public func register(type: CompanionObject) {
        types[type.name] = .companionObject(type)
    }

    func resolve(typeNamed name: Located<String>?) -> ResolvedType? {
        guard let resolved = name.flatMap({ BuiltinType(rawValue: $0.value) }).map({ ResolvedType.builtin($0) })
            ?? name.flatMap({ self.type(forName: $0.value) })
        else { return nil}

        return resolved
    }
}
