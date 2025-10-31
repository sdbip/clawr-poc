public enum Expression: Equatable {
    case boolean(Bool)
    case integer(Int64)
    case real(Double)
    case bitfield(UInt64)
}

extension Expression {
    var type: ResolvedType {
        switch self {
        case .boolean(_): .boolean
        case .integer(_): .integer
        case .real(_): .real
        case .bitfield(_): .bitfield
        }
    }
}
