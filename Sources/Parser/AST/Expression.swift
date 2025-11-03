public enum Expression: Equatable {
    case boolean(Bool)
    case integer(Int64)
    case real(Double)
    case bitfield(UInt64)
    case identifier(String, type: ResolvedType)
    case dataStructureLiteral(ResolvedType, fieldValues: [String: Expression])
    case memberLookup(LookupTarget)
}

public indirect enum LookupTarget: Equatable {
    case expression(Expression)
    case member(LookupTarget, member: String, type: ResolvedType)
}

public extension LookupTarget {
    var type: ResolvedType {
        switch self {
        case .member(_, member: _, type: let type): type
        case .expression(let expr): expr.type
        }
    }
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
        case .memberLookup(let target): target.type
        }
    }
}
