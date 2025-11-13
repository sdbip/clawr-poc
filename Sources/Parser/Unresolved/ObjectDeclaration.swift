import Lexer

struct ObjectDeclaration {
    var name: Located<String>
    var isAbstract: Bool
    var supertype: Located<String>?
    var pureMethods: [FunctionDeclaration] = []
    var mutatingMethods: [FunctionDeclaration] = []
    var fields: [VariableDeclaration] = []
    var factoryMethods: [FunctionDeclaration] = []
    var staticMethods: [FunctionDeclaration] = []
    var staticFields: [VariableDeclaration] = []
}

extension ObjectDeclaration: StatementParseable {
    var asStatement: UnresolvedStatement {
        return .objectDeclaration(self)
    }

    static func isNext(in stream: TokenStream) -> Bool {
        return stream.peek()?.value == "object"
    }

    init(parsing stream: TokenStream) throws {
        _ = try stream.next().requiring { $0.value == "object" }

        let isAbstract: Bool
        let supertype : Located<String>?
        if stream.peek()?.value == "abstract" {
            _ = stream.next()
            isAbstract = true
        } else {
            isAbstract = false
        }

        let nameToken = try stream.next().requiring { $0.kind == .identifier }

        if stream.peek()?.value == ":" {
            _ = stream.next()
            let supertypeToken = try stream.next().requiring { $0.kind == .identifier }
            supertype = (supertypeToken.value, supertypeToken.location)
        } else {
            supertype = nil
        }

        var pureMethods: [FunctionDeclaration] = []
        var mutatingMethods: [FunctionDeclaration]? = nil
        var factoryMethods: [FunctionDeclaration]? = nil
        var staticMethods: [FunctionDeclaration]? = nil
        var staticFields: [VariableDeclaration]? = nil
        var dataFields: [VariableDeclaration]? = nil

        _ = try stream.next().requiring { $0.value == "{" }

        while let t = stream.peek(), !sectionEnders.contains(t.value) {
            let method = try FunctionDeclaration(parsing: stream)
            pureMethods.append(method)
        }

        while let t = stream.peek(), t.value != "}" {
            if t.value == "factory" {
                if factoryMethods != nil { throw ParserError.invalidToken(t) }
                _ = stream.next()
                _ = try stream.next().requiring { $0.value == ":" }

                var methods: [FunctionDeclaration] = []
                while let t = stream.peek(), !sectionEnders.contains(t.value)  {
                    var method = try FunctionDeclaration(parsing: stream)
                    if let returnType = method.returnType, returnType.value != nameToken.value { throw ParserError.unresolvedType(returnType.location) }
                    method.returnType = method.returnType ?? (nameToken.value, location: nameToken.location)
                    methods.append(method)
                }
                factoryMethods = methods
            }

            if t.value == "mutating" {
                if mutatingMethods != nil { throw ParserError.invalidToken(t) }
                _ = stream.next()
                _ = try stream.next().requiring { $0.value == ":" }

                var methods: [FunctionDeclaration] = []
                while let t = stream.peek(), !sectionEnders.contains(t.value)  {
                    let method = try FunctionDeclaration(parsing: stream)
                    methods.append(method)
                }

                mutatingMethods = methods
            }

            if t.value == "static" {
                if staticFields != nil { throw ParserError.invalidToken(t) }
                _ = stream.next()
                _ = try stream.next().requiring { $0.value == ":" }

                var fields: [VariableDeclaration] = []
                var methods: [FunctionDeclaration] = []
                while let t = stream.peek(), !sectionEnders.contains(t.value)  {
                    if FunctionDeclaration.isNext(in: stream) {
                        try methods.append(FunctionDeclaration(parsing: stream))
                    } else if VariableDeclaration.isNext(in: stream) {
                        try fields.append(VariableDeclaration(parsing: stream))
                    } else {
                        throw ParserError.invalidToken(t)
                    }
                }

                staticFields = fields
                staticMethods = methods
            }

            if t.value == "data" {
                if dataFields != nil { throw ParserError.invalidToken(t) }
                _ = stream.next()
                _ = try stream.next().requiring { $0.value == ":" }

                var fields: [VariableDeclaration] = []
                while let t = stream.peek(), !sectionEnders.contains(t.value)  {
                    try fields.append(VariableDeclaration(parsing: stream, defaultSemantics: .isolated))

                    if stream.peek()?.value == "," {
                        _ = stream.next()
                    } else if stream.peek(skippingNewlines: false)?.value == "\n" {
                        _ = stream.next(skippingNewlines: false)
                    }
                }

                dataFields = fields
            }
        }
        _ = try stream.next().requiring { $0.value == "}" }

        self.init(
            name: (nameToken.value, location: nameToken.location),
            isAbstract: isAbstract,
            supertype: supertype,
            pureMethods: pureMethods,
            mutatingMethods: mutatingMethods ?? [],
            fields: dataFields ?? [],
            factoryMethods: factoryMethods ?? [],
            staticMethods: staticMethods ?? [],
            staticFields: staticFields ?? [],
        )
    }

    func resolveObject(in scope: Scope) throws -> Object {

        var companionObject = Object(name: "\(name.value).static")
        companionObject.fields = try staticFields.map { try $0.resolveVariable(in: scope) }
        scope.register(type: companionObject)
        scope.register(variable: Variable(name: name.value, semantics: .immutable, type: .object(companionObject)))

        var result = Object(name: name.value, isAbstract: isAbstract, supertype: scope.resolve(typeNamed: supertype))
        result.fields = try fields.map { try $0.resolveVariable(in: scope) }

        let objectScope = Scope(parent: scope, parameters: [Variable(name: "self", semantics: .immutable, type: .object(result))])
        objectScope.register(type: result)

        result.pureMethods = try pureMethods.map { try $0.resolveFunction(in: objectScope) }
        result.mutatingMethods = try mutatingMethods.map { try $0.resolveFunction(in: objectScope) }
        result.factoryMethods = try factoryMethods.map { try $0.resolveFunction(in: objectScope) }

        result.staticFields = try staticFields.map { try $0.resolveVariable(in: scope) }
        result.staticMethods = try staticMethods.map { try $0.resolveFunction(in: scope) }

        return result
    }
}

let sectionEnders = [
    "data", "static", "mutating", "factory", "}"
]
