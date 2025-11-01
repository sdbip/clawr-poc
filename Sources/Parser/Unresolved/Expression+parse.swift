import Lexer

extension Expression {
    static func parse(stream: TokenStream, in scope: Scope) throws -> Located<Expression> {
        let token = try stream.next().required()

        return try (value: expr(), location: token.location)

        func expr() throws -> Expression {
            switch token.value {
            case "true": return .boolean(true)
            case "false": return .boolean(false)
            case let v where token.kind == .decimal:
                if let i = Int64(v.replacing("_", with: "")) {
                    return .integer(i)
                } else if let r = Double(v.replacing("_", with: "")) {
                    return .real(r)
                }
                throw ParserError.invalidToken(token)

            case let v where token.kind == .binary:
                if v.hasPrefix("0x"), let b = UInt64(v.dropFirst(2).replacing("_", with: ""), radix: 16) {
                    return .bitfield(b)
                } else if v.hasPrefix("0b"), let b = UInt64(v.dropFirst(2).replacing("_", with: ""), radix: 2) {
                    return .bitfield(b)
                }
                throw ParserError.invalidToken(token)

            case let v where token.kind == .identifier:
                guard let variable = scope.variable(forName: v) else { throw ParserError.unknownVariable(v,  token.location) }
                return .identifier(v, type: variable.type)

            default:
                throw ParserError.invalidToken(token)
            }
        }
    }
}
