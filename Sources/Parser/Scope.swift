public class Scope {
    private let parent: Scope?

    private var variables: [String : Variable] = [:]

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
}
