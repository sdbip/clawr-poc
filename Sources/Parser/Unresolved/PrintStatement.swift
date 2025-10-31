import Lexer

struct PrintStatement {
    var expression: Expression
}

extension PrintStatement {
    init(parsing stream: TokenStream) throws {
        _ = try stream.next().requiring { $0.value == "print" }
        try self.init(expression: Expression.parse(stream: stream).value)
    }
}
