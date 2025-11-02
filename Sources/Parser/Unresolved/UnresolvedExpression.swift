import Lexer

enum UnresolvedExpression: Equatable {
    case boolean(Bool, location: FileLocation)
    case integer(Int64, location: FileLocation)
    case real(Double, location: FileLocation)
    case bitfield(UInt64, location: FileLocation)
    case identifier(String, location: FileLocation)
}

extension UnresolvedExpression {
    var location: FileLocation {
        switch self {
        case .boolean(_, let l),
             .integer(_, let l),
             .bitfield(_, let l),
             .real(_, let l),
             .identifier(_, let l):
                return l
        }
    }
    static func parse(stream: TokenStream) throws -> UnresolvedExpression {
        let token = try stream.next().required()

        return try expr()

        func expr() throws -> UnresolvedExpression {
            switch token.value {
            case "true": return .boolean(true, location: token.location)
            case "false": return .boolean(false, location: token.location)
            case let v where token.kind == .decimal:
                if let i = Int64(v.replacing("_", with: "")) {
                    return .integer(i, location: token.location)
                } else if let r = Double(v.replacing("_", with: "")) {
                    return .real(r, location: token.location)
                }
                throw ParserError.invalidToken(token)

            case let v where token.kind == .binary:
                if v.hasPrefix("0x"), let b = UInt64(v.dropFirst(2).replacing("_", with: ""), radix: 16) {
                    return .bitfield(b, location: token.location)
                } else if v.hasPrefix("0b"), let b = UInt64(v.dropFirst(2).replacing("_", with: ""), radix: 2) {
                    return .bitfield(b, location: token.location)
                }
                throw ParserError.invalidToken(token)

            case let v where token.kind == .identifier:
                return .identifier(v, location: token.location)

            default:
                throw ParserError.invalidToken(token)
            }
        }
    }

    func resolve(in scope: Scope) throws -> Expression {

        switch self {
        case .boolean(let b, _): return .boolean(b)
        case .integer(let i, _): return .integer(i)
        case .real(let b, _): return .real(b)
        case .bitfield(let b, _): return .bitfield(b)
        case .identifier(let v, let location):
            guard let variable = scope.variable(forName: v) else { throw ParserError.unknownVariable(v,  location) }
            return .identifier(v, type: variable.type)
        }
    }
}
