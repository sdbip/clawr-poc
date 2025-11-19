import Lexer

struct FunctionCall {
    var function: Located<String>
    var arguments: [Labeled<UnresolvedExpression>]
    var returnType: Located<String>?

    var resolvedName: String {
        Function.resolvedName(base: function.value, labels: arguments.map { $0.label })
    }
}

struct MethodCall {
    var target: UnresolvedExpression
    var functionCall: FunctionCall
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
            let clone = stream.clone()
            _ = clone.next()
            if clone.peek()?.value == ":" {
                let label = try stream.next().requiring { $0.kind == .identifier }.value
                _ = stream.next()
                let expression = try UnresolvedExpression.parse(stream: stream)
                arguments.append(.labeled(expression, label: label))
            } else {
                let expression = try UnresolvedExpression.parse(stream: stream)
                arguments.append(.unlabeled(expression))
            }

            if stream.peek()?.value == "," {
                _ = stream.next()
            } else {
                break
            }
        }
        _ = try stream.next().requiring { $0.value == ")" }
        self.init(function: (name, location: nameToken.location), arguments: arguments)
    }
}
