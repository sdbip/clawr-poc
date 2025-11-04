import Lexer

struct FunctionCall {
    var target: Located<String>
    var arguments: [Labeled<UnresolvedExpression>]

    var resolvedName: String {
        Function.resolvedName(base: target.value, labels: arguments.map { $0.label })
    }
}

extension FunctionCall: StatementParseable {
    static func isNext(in stream: TokenStream) -> Bool {
        return true
    }

    var asStatement: UnresolvedStatement {
        return .functionCall(self)
    }

    init(parsing stream: TokenStream) throws {
        let nameToken = try stream.next().requiring { $0.kind == .identifier }
        let name = nameToken.value
        _ = try stream.next().requiring { $0.value == "("}
        var arguments: [Labeled<UnresolvedExpression>] = []
        while stream.peek()?.value != ")" {
            let expression = try UnresolvedExpression.parse(stream: stream)
            arguments.append(.unlabeled(expression))
            if stream.peek()?.value == "," {
                _ = stream.next()
            } else {
                break
            }
        }
        _ = try stream.next().requiring { $0.value == ")" }
        self.init(target: (name, location: nameToken.location), arguments: arguments)
    }
}
