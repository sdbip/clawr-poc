import Lexer

struct DataStructureLiteral {
    var fieldValues: [String: UnresolvedExpression]
}

extension DataStructureLiteral {
    static func parse(stream: TokenStream) throws -> DataStructureLiteral {
        _ = try stream.next().requiring { $0.value == "{" }
        var fieldValues: [String: UnresolvedExpression] = [:]
        while stream.peek()?.value != "}" {
            let name = try stream.next().requiring { $0.kind == .identifier }.value
            _ = try stream.next().requiring { $0.value == ":" }
            let expression = try UnresolvedExpression.parse(stream: stream)

            fieldValues[name] = expression

            if stream.peek()?.value == "," {
                _ = stream.next()
            } else if stream.peek()?.value == "}" {
                break
            } else {
                _ = try stream.next(skippingNewlines: false).requiring { $0.value == "\n" }
            }
        }

        _ = try stream.next().requiring { $0.value == "}" }
        return DataStructureLiteral(fieldValues: fieldValues)
    }
}
