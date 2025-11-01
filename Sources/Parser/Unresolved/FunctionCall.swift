import Lexer

public struct FunctionCall: Equatable {
    public var target: String
    public var arguments: [Labeled<Expression>]

    public init(target: String, arguments: [Labeled<Expression>]) {
        self.target = target
        self.arguments = arguments
    }
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

    func resolve() throws -> Statement {
        return .functionCall(target, arguments: arguments)
    }
}
