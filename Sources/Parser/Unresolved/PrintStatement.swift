import Lexer

struct PrintStatement {
    var expression: Expression
}

extension PrintStatement {
    static func isNext(in stream: TokenStream) -> Bool {
        return stream.peek()?.value == "print"
    }

    init(parsing stream: TokenStream, in scope: Scope) throws {
        _ = try stream.next().requiring { $0.value == "print" }
        try self.init(expression: Expression.parse(stream: stream, in: scope).value)
    }
}
