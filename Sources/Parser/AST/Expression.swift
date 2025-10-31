public enum Expression: Equatable {
    case integer(Int64)
}

extension Expression {
    var type: String {
        switch self {
        case .integer(_): "integer"
        }
    }
}
