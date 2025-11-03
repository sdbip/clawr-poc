import Lexer

enum UnresolvedExpression: Equatable {
    case boolean(Bool, location: FileLocation)
    case integer(Int64, location: FileLocation)
    case real(Double, location: FileLocation)
    case bitfield(UInt64, location: FileLocation)
    case identifier(String, location: FileLocation)
    case dataStructureLiteral(DataStructureLiteral, location: FileLocation)
    case memberLookup(UnresolvedLookupTarget)
}

indirect enum UnresolvedLookupTarget: Equatable {
    case expression(UnresolvedExpression, location: FileLocation)
    case member(UnresolvedLookupTarget, member: String, location: FileLocation)
}

extension UnresolvedExpression {
    var location: FileLocation {
        switch self {
        case .boolean(_, let l),
             .integer(_, let l),
             .bitfield(_, let l),
             .real(_, let l),
             .dataStructureLiteral(_, let l),
             .memberLookup(.expression(_, location: let l)),
             .memberLookup(.member(_, member: _, location: let l)),
             .identifier(_, let l):
                return l
        }
    }
    static func parse(stream: TokenStream) throws -> UnresolvedExpression {
        let token = try stream.peek().required()

        let expression = try expr()
        if stream.peek()?.value == "." {
            _ = stream.next()
            let memberToken = try stream.next().requiring { $0.kind == .identifier }

            let expression2: UnresolvedExpression = .memberLookup(.member(
                .expression(expression, location: token.location),
                member: memberToken.value,
                location: memberToken.location
            ))
            if stream.peek()?.value == "." {
                _ = stream.next()
                let memberToken2 = try stream.next().requiring { $0.kind == .identifier }
                return .memberLookup(.member(
                    .expression(expression2, location: memberToken.location),
                    member: memberToken2.value,
                    location: memberToken2.location
                ))
            }

            return expression2
        }

        return expression

        func expr() throws -> UnresolvedExpression {
            switch token.value {
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
        }
    }

    private func resolve(lookup: UnresolvedLookupTarget, in scope: Scope) throws -> LookupTarget {
        switch lookup {
        case .expression(let expression, location: let location):
            return .expression(try expression.resolve(in: scope, declaredType: nil))
        case .member(let target, member: let member, location: let location):
            let parent = try resolve(lookup: target, in: scope)
            guard case .data(let data) = parent.type else { throw ParserError.unresolvedType(location) }
            guard let field = data.fields.first(where: { $0.name == member }) else { throw ParserError.unknownVariable(member, location) }
            return .member(parent, member: member, type: field.type)
        }
    }
}
