import Lexer

indirect enum UnresolvedExpression {
    case boolean(Bool, location: FileLocation)
    case integer(Int64, location: FileLocation)
    case real(Double, location: FileLocation)
    case bitfield(UInt64, location: FileLocation)
    case identifier(String, location: FileLocation)
    case functionCall(FunctionCall)
    case methodCall(MethodCall)
    case dataStructureLiteral(DataStructureLiteral, location: FileLocation)
    case memberLookup(UnresolvedExpression, member: String, location: FileLocation)
    case unaryOperation(operator: UnaryOperator, expression: UnresolvedExpression, location: FileLocation)
    case binaryOperation(left: UnresolvedExpression, operator: BinaryOperator, right: UnresolvedExpression, location: FileLocation)
}

extension UnresolvedExpression {
    var location: FileLocation {
        switch self {
        case .boolean(_, let l): return l
        case .integer(_, let l): return l
        case .bitfield(_, let l): return l
        case .real(_, let l): return l
        case .dataStructureLiteral(_, let l): return l
        case .memberLookup(_, _, location: let l): return l
        case .methodCall(let call): return call.functionCall.function.location
        case .identifier(_, let l): return l
        case .unaryOperation(_, _, location: let l): return l
        case .binaryOperation(_, _, _, location: let l): return l
        case .functionCall(let call): return call.function.location
        }
    }

    static func parse(stream: TokenStream) throws -> UnresolvedExpression {
        let expression = try expression(parsing: stream)
        return try lookup(current: expression)

        func lookup(current: UnresolvedExpression) throws -> UnresolvedExpression {
            guard stream.peek()?.value == "." else { return current }
            _ = stream.next()

            if FunctionCall.isNext(in: stream) {
                return try lookup(current: .methodCall(MethodCall(
                    target: current,
                    functionCall: FunctionCall(parsing: stream)
                )))
            } else {
                let memberToken = try stream.next().requiring { $0.kind == .identifier }
                return try lookup(current: .memberLookup(
                    current,
                    member: memberToken.value,
                    location: memberToken.location
                ))
            }

        }
    }

    static func expression(parsing stream: TokenStream, precedence p: Int = 0) throws -> UnresolvedExpression {
        var left = try prefixExpression(parsing: stream)

        while let token = stream.peek(), let op = BinaryOperator(rawValue: token.value) {
            if op.precedence < p { break }

            _ = stream.next()
            let right = try expression(parsing: stream, precedence: op.precedence + 1)
            left = .binaryOperation(left: left, operator: op, right: right, location: token.location)
        }

        return left
    }

    static func prefixExpression(parsing stream: TokenStream) throws -> UnresolvedExpression {
        let token = try stream.peek().required()
        if let op = prefixOperator(for: token.value) {
            _ = stream.next()
            return try .unaryOperation(operator: op, expression: prefixExpression(parsing: stream), location: token.location)
        }

        switch token.value {
        case "(":
            _ = stream.next()
            let expr = try expression(parsing: stream)
            _ = try stream.next().requiring { $0.value == ")" }
            return expr

        case "true":
            _ = stream.next()
            return .boolean(true, location: token.location)

        case "false":
            _ = stream.next()
            return .boolean(false, location: token.location)

        case "{":
            return try .dataStructureLiteral(DataStructureLiteral.parse(stream: stream), location: token.location)

        case let v where token.kind == .decimal:
            _ = stream.next()
            if let i = Int64(v.replacing("_", with: "")) {
                return .integer(i, location: token.location)
            } else if let r = Double(v.replacing("_", with: "")) {
                return .real(r, location: token.location)
            }
            throw ParserError.invalidToken(token)

        case let v where token.kind == .binary:
            _ = stream.next()
            if v.hasPrefix("0x"), let b = UInt64(v.dropFirst(2).replacing("_", with: ""), radix: 16) {
                return .bitfield(b, location: token.location)
            } else if v.hasPrefix("0b"), let b = UInt64(v.dropFirst(2).replacing("_", with: ""), radix: 2) {
                return .bitfield(b, location: token.location)
            }
            throw ParserError.invalidToken(token)

        case let v where token.kind == .identifier, let v where v == "self":
            _ = stream.next()
            return .identifier(v, location: token.location)

        default:
            throw ParserError.invalidToken(token)
        }
    }

    func resolve(in scope: Scope, declaredType: String?) throws -> Expression {

        switch self {
        case .boolean(let b, _): return .boolean(b)
        case .integer(let i, _): return .integer(i)
        case .real(let b, _): return .real(b)
        case .bitfield(let b, _): return .bitfield(b)
        case .identifier(let v, let location):
            guard let variable = scope.variable(forName: v) else { throw ParserError.unknownVariable(v,  location) }
            return .identifier(v, type: variable.type)
        case .methodCall(let call):
            let target = try call.target.resolve(in: scope, declaredType: nil)
            let resolvedName = call.functionCall.resolvedName
            switch target.type {
            case .companionObject(let object):
                guard let function = object.methods.first(where: { $0.resolutionName == resolvedName }) else { throw ParserError.unknownFunction(resolvedName, call.functionCall.function.location) }
                guard let returnType = function.returnType else { throw ParserError.unresolvedType(call.functionCall.returnType?.location ?? call.functionCall.function.location)}
                return try .methodCall(
                    call.functionCall.function.value,
                    target: call.target.resolve(in: scope, declaredType: nil),
                    arguments: call.functionCall.arguments.enumerated().map {
                        let parameter = function.parameters[$0.offset]
                        return try $0.element.map { try $0.resolve(in: scope, declaredType: parameter.value.type.name) }
                    },
                    type: returnType)
            default: throw ParserError.unresolvedType(call.target.location)
            }
        case .functionCall(let call):
            let resolvedName = call.resolvedName
            guard let function = scope.function(forName: resolvedName) else { throw ParserError.unknownFunction(resolvedName, call.function.location) }
            guard let returnType = scope.resolve(typeNamed: call.returnType) else { throw ParserError.unresolvedType(call.returnType?.location ?? call.function.location)}
            return try .functionCall(
                call.function.value,
                arguments: call.arguments.enumerated().map {
                    let parameter = function.parameters[$0.offset]
                    return try $0.element.map { try $0.resolve(in: scope, declaredType: parameter.value.type.name) }
                },
                type: returnType)

        case .dataStructureLiteral(let literal, location: let location):
            guard let declaredType else { throw ParserError.unresolvedType(location) }
            switch scope.resolve(typeNamed: (declaredType, location)) {
            case .data(let dataType):
                let fieldValues = try literal.fieldValues.map { (key, value) in
                    guard let field = dataType.fields.first(where: { $0.name == key }) else { throw ParserError.unknownVariable(key, location) }
                    // TODO: This converts the already resolved type back to String to be resolved again
                    return (key, try value.resolve(in: scope, declaredType: field.type.name))
                }
                return .dataStructureLiteral(.data(dataType), fieldValues: Dictionary(uniqueKeysWithValues: fieldValues))
            case .object(let objectType):
                let fieldValues = try literal.fieldValues.map { (key, value) in
                    guard let field = objectType.fields.first(where: { $0.name == key }) else { throw ParserError.unknownVariable(key, location) }
                    // TODO: This converts the already resolved type back to String to be resolved again
                    return (key, try value.resolve(in: scope, declaredType: field.type.name))
                }
                return .dataStructureLiteral(.object(objectType), fieldValues: Dictionary(uniqueKeysWithValues: fieldValues))
            default:
                throw ParserError.unresolvedType(location)
            }
        case .memberLookup(let target, member: let member, location: let location):
            let parent = try target.resolve(in: scope, declaredType: nil)
            switch parent.type {
            case .data(let data):
                guard let field = data.fields.first(where: { $0.name == member }) else { throw ParserError.unknownVariable(member, location) }
                return .memberLookup(parent, member: member, type: field.type)
            case .object(let object):
                guard let field = object.fields.first(where: { $0.name == member }) else { throw ParserError.unknownVariable(member, location) }
                return .memberLookup(parent, member: member, type: field.type)
            case .companionObject(let object):
                guard let field = object.fields.first(where: { $0.name == member }) else { throw ParserError.unknownVariable(member, location) }
                return .memberLookup(parent, member: member, type: field.type)
            default:
                throw ParserError.unresolvedType(location)
            }
        case .unaryOperation(operator: let op, expression: let expr, location: let location):
            // TODO: Check that the resolved type supports ~x
            return try .unaryOperation(operator: op, expression: expr.resolve(in: scope, declaredType: declaredType))
        case .binaryOperation(left: let left, operator: let op, right: let right, location: let location):
            // TODO: Check that the resolved type supports x << n
            return try .binaryOperation(left: left.resolve(in: scope, declaredType: declaredType), operator: op, right: right.resolve(in: scope, declaredType: nil))
        }
    }
}

private func prefixOperator(for token: String) -> UnaryOperator? {
    switch token {
    case "~": .bitfieldNegation
    default: nil
    }
}
