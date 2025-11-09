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
        case .memberLookup(.member(_, member: _, location: let l)): return l
        case .identifier(_, let l): return l
        case .unaryOperation(operator: _, expression: _, location: let l): return l
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

    static func expression(parsing stream: TokenStream) throws -> UnresolvedExpression {
        let expression = try prefixExpression(parsing: stream)
        switch stream.peek() {
        case .some(let token) where token.value == "<<":
            _ = stream.next()
            return try .binaryOperation(left: expression, operator: .leftShift, right: self.expression(parsing: stream), location: token.location)
        case .some(let token) where token.value == ">>":
            _ = stream.next()
            return try .binaryOperation(left: expression, operator: .rightShift, right: self.expression(parsing: stream), location: token.location)
        default: return expression
        }
    }

    static func prefixExpression(parsing stream: TokenStream) throws -> UnresolvedExpression {
        let token = try stream.peek().required()
        switch token.value {
        case "~":
            _ = stream.next()
            return try .unaryOperation(operator: .bitfieldNegation, expression: prefixExpression(parsing: stream), location: token.location)
        case "true":
            _ = stream.next()
            return .boolean(true, location: token.location)
        case "false":
            _ = stream.next()
            return .boolean(false, location: token.location)
        case "{" :
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
            guard case .some(.data(let dataType)) = scope.resolve(typeNamed: (declaredType, location)) else { throw ParserError.unresolvedType(location) }
            let fieldValues = try literal.fieldValues.map { (key, value) in
                let field = dataType.fields.first { $0.name == key }
                // TODO: This converts the already resolved type back to String to be resolved again
                return (key, try value.resolve(in: scope, declaredType: field?.type.name))
            }
            return .dataStructureLiteral(.data(dataType), fieldValues: Dictionary(uniqueKeysWithValues: fieldValues))
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
