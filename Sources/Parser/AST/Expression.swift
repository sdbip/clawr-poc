public indirect enum Expression: Equatable {
    case boolean(Bool)
    case integer(Int64)
    case real(Double)
    case bitfield(UInt64)
    case identifier(String, type: ResolvedType)
    case functionCall(String, arguments: [Labeled<Expression>], type: ResolvedType)
    case methodCall(String, target: Expression, arguments: [Labeled<Expression>], type: ResolvedType)
    case dataStructureLiteral(ResolvedType, fieldValues: [String: Expression])
    case memberLookup(Expression, member: String, type: ResolvedType)
    case unaryOperation(operator: UnaryOperator, expression: Expression)
    case binaryOperation(left: Expression, operator: BinaryOperator, right: Expression)
}

public enum UnaryOperator: Equatable {
    case bitfieldNegation
}

public enum BinaryOperator: String {
    case leftShift      = "<<"
    case rightShift     = ">>"
    case addition       = "+"
    case subtraction    = "-"
    case multiplication = "*"

    var precedence: Int {
        return self == .multiplication ? 1 : 0
    }
}

extension Expression {
    public var type: ResolvedType {
        switch self {
        case .boolean(_): .builtin(.boolean)
        case .integer(_): .builtin(.integer)
        case .real(_): .builtin(.real)
        case .bitfield(_): .builtin(.bitfield)
        case .identifier(_, type: let t): t
        case .functionCall(_, _, type: let t): t
        case .methodCall(_, _, _, type: let t): t
        case .dataStructureLiteral(let t, fieldValues: _): t
        case .memberLookup(let target): target.type
        case .unaryOperation(operator: _, expression: let ex): ex.type
        case .binaryOperation(left: let ex, operator: _, right: _): ex.type
        }
    }
}
