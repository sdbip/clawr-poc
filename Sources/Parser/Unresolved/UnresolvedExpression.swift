import Lexer

indirect enum UnresolvedExpression: Equatable {
    case boolean(Bool, location: FileLocation)
    case integer(Int64, location: FileLocation)
    case real(Double, location: FileLocation)
    case bitfield(UInt64, location: FileLocation)
    case identifier(String, location: FileLocation)
    case dataStructureLiteral(DataStructureLiteral, location: FileLocation)
    case memberLookup(UnresolvedLookupTarget)
    case unaryOperation(operator: UnaryOperator, expression: UnresolvedExpression, location: FileLocation)
    case binaryOperation(left: UnresolvedExpression, operator: BinaryOperator, right: UnresolvedExpression, location: FileLocation)
}

indirect enum UnresolvedLookupTarget: Equatable {
    case expression(UnresolvedExpression)
    case member(UnresolvedLookupTarget, member: String, location: FileLocation)
}

extension UnresolvedExpression {
    var location: FileLocation {
        switch self {
        case .memberLookup(.expression(let e)): return e.location
        case .boolean(_, let l): return l
        case .integer(_, let l): return l
        case .bitfield(_, let l): return l
        case .real(_, let l): return l
        case .dataStructureLiteral(_, let l): return l
        case .memberLookup(.member(_, _, location: let l)): return l
        case .identifier(_, let l): return l
        case .unaryOperation(_, _, location: let l): return l
        case .binaryOperation(_, _, _, location: let l): return l
        }
    }
    static func parse(stream: TokenStream) throws -> UnresolvedExpression {
        let expression = try expression(parsing: stream)
        return try lookup(current: expression)

        func lookup(current: UnresolvedExpression) throws -> UnresolvedExpression {
            if stream.peek()?.value == "." {
                _ = stream.next()
                let memberToken = try stream.next().requiring { $0.kind == .identifier }
                return try lookup(current: .memberLookup(.member(
                    .expression(current),
                    member: memberToken.value,
                    location: memberToken.location
                )))
            }

            return current
        }
    }

    static func expression(parsing stream: TokenStream, precedence p: Int = 0) throws -> UnresolvedExpression {
        var left = try prefixExpression(parsing: stream)

        while let token = stream.peek(), let op = binaryOperator(for: token.value) {
            let currentPrecedence = precedence(of: op)
            if currentPrecedence < p { break }

            _ = stream.next() // consume operator
            let right = try expression(parsing: stream, precedence: currentPrecedence + 1)
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

        case let v where token.kind == .identifier:
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
        case .dataStructureLiteral(let literal, location: let location):
            guard let declaredType else { throw ParserError.unresolvedType(location) }
            switch scope.resolve(typeNamed: (declaredType, location)) {
            case .data(let dataType):
                let fieldValues = try literal.fieldValues.map { (key, value) in
                    let field = dataType.fields.first { $0.name == key }
                    // TODO: This converts the already resolved type back to String to be resolved again
                    return (key, try value.resolve(in: scope, declaredType: field?.type.name))
                }
                return .dataStructureLiteral(.data(dataType), fieldValues: Dictionary(uniqueKeysWithValues: fieldValues))
            case .object(let objectType):
                let fieldValues = try literal.fieldValues.map { (key, value) in
                    let field = objectType.fields.first { $0.name == key }
                    // TODO: This converts the already resolved type back to String to be resolved again
                    return (key, try value.resolve(in: scope, declaredType: field?.type.name))
                }
                return .dataStructureLiteral(.object(objectType), fieldValues: Dictionary(uniqueKeysWithValues: fieldValues))
            default:
                throw ParserError.unresolvedType(location)
            }
        case .memberLookup(let lookup):
            return .memberLookup(try resolve(lookup: lookup, in: scope))
        case .unaryOperation(operator: let op, expression: let expr, location: let location):
            // TODO: Check that the resolved type supports ~x
            return try .unaryOperation(operator: op, expression: expr.resolve(in: scope, declaredType: declaredType))
        case .binaryOperation(left: let left, operator: let op, right: let right, location: let location):
            // TODO: Check that the resolved type supports x << n
            return try .binaryOperation(left: left.resolve(in: scope, declaredType: declaredType), operator: op, right: right.resolve(in: scope, declaredType: nil))
        }
    }

    private func resolve(lookup: UnresolvedLookupTarget, in scope: Scope) throws -> LookupTarget {
        switch lookup {
        case .expression(let expression):
            return .expression(try expression.resolve(in: scope, declaredType: nil))
        case .member(let target, member: let member, location: let location):
            let parent = try resolve(lookup: target, in: scope)
            guard case .data(let data) = parent.type else { throw ParserError.unresolvedType(location) }
            guard let field = data.fields.first(where: { $0.name == member }) else { throw ParserError.unknownVariable(member, location) }
            return .member(parent, member: member, type: field.type)
        }
    }
}

private func binaryOperator(for token: String) -> BinaryOperator? {
    switch token {
    case "<<": .leftShift
    case ">>": .rightShift
    case "+": .addition
    case "-": .subtraction
    case "*": .multiplication
    default: nil
    }
}

private func precedence(of op: BinaryOperator) -> Int {
    return op == .multiplication ? 1 : 0
}

private func prefixOperator(for token: String) -> UnaryOperator? {
    switch token {
    case "~": .bitfieldNegation
    default: nil
    }
}
