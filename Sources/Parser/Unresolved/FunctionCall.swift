import Lexer

struct FunctionCall: Equatable {
    var target: String
    var arguments: [Labeled<Expression>]
}

extension FunctionCall: StatementParseable {
    static func isNext(in stream: TokenStream) -> Bool {
        return true
    }

    init(parsing stream: TokenStream, in scope: Scope) throws {
        let name = try stream.next().requiring { $0.kind == .identifier }.value
        _ = try stream.next().requiring { $0.value == "("}
        var arguments: [Labeled<Expression>] = []
        while stream.peek()?.value != ")" {
            let expression = try Expression.parse(stream: stream, in: scope)
            arguments.append(.unlabeled(expression.value))
            if stream.peek()?.value == "," {
                _ = stream.next()
            } else {
                break
            }
        }
        _ = try stream.next().requiring { $0.value == ")" }
        self.init(target: name, arguments: arguments)
    }

    func resolve(in scope: Scope) throws -> Statement {
        return .functionCall(target, arguments: arguments)
    }
}
