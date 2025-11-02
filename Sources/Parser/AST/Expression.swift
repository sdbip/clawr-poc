public enum Expression: Equatable {
    case boolean(Bool)
    case integer(Int64)
    case real(Double)
    case bitfield(UInt64)
    case identifier(String, type: ResolvedType)
    case dataStructureLiteral(ResolvedType, fieldValues: [String: Expression])
}

extension Expression {
    var type: ResolvedType {
        switch self {
        case .boolean(_): .builtin(.boolean)
        case .integer(_): .builtin(.integer)
        case .real(_): .builtin(.real)
        case .bitfield(_): .builtin(.bitfield)
        case .identifier(_, type: let t): t
        case .dataStructureLiteral(let t, fieldValues: _): t
        }
    }
}
