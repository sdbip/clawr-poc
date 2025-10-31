import Lexer

struct PrintStatement {
    var expression: Expression
}

extension PrintStatement {
    static func parse(stream: TokenStream) throws -> PrintStatement {
        _ = try stream.next().requiring { $0.value == "print" }
        let expressionToken = try stream.next().required()

        if expressionToken.value == "true" {
            return PrintStatement(expression: .boolean(true))
        } else if expressionToken.value == "false" {
            return PrintStatement(expression: .boolean(false))
        } else if expressionToken.value.contains(".") {
            return PrintStatement(expression: .real(Double(expressionToken.value)!))
        } else if expressionToken.value.hasPrefix("0x") {
            return PrintStatement(expression: .bitfield(UInt64(expressionToken.value[expressionToken.value.index(expressionToken.value.startIndex, offsetBy: 2)...], radix: 16)!))
        } else if expressionToken.value.hasPrefix("0b") {
            return PrintStatement(expression: .bitfield(UInt64(expressionToken.value[expressionToken.value.index(expressionToken.value.startIndex, offsetBy: 2)...], radix: 2)!))
        } else {
            return PrintStatement(expression: .integer(Int64(expressionToken.value)!))
        }
    }
}
