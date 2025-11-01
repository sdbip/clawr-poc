import Parser
import Codegen

public func irgen(ast: [Parser.Statement]) -> [Codegen.Statement] {
    var statements: [Codegen.Statement] = []
    for statement in ast {
        switch statement {
        case .variableDeclaration(let variable, initializer: let initializer):
            statements.append(.variable(variable.name, type: variable.type.rawValue, initializer: initializer.map(irgen(expression:)) ?? .literal("NULL")))
        case .functionDeclaration(let name, returns: let returnType, parameters: let parameters, body: let body):
            fatalError("functionDeclaration not yet implemented!!")
        case .functionCall(_, arguments: _):
            fatalError("functionCall not yet implemented!!")
        case .printStatement(let expression):
            statements.append(.call(.name("print"), arguments: [toString(expression: expression)]))
        }
    }
    return [
        .function(
            "main",
            returns: "int",
            parameters: [],
            body: statements)
    ]
}

func irgen(expression: Parser.Expression) -> Codegen.Expression {
    switch expression {
    case .boolean(let b): .literal(b ? "1" : "0")
    case .integer(let i): .literal("\(i)")
    case .real(let r): .literal("\(1/r)")
    case .bitfield(let b): .literal("\(b)")
    case .identifier(let identifier, type: _): .reference(.name(identifier))
    }
}

func toString(expression: Parser.Expression) -> Codegen.Expression {
    switch expression {
    case .boolean(let b): .call(.name("boolean_toString"), arguments: [.literal(b ? "1" : "0")])
    case .integer(let i): .call(.name("integer_toString"), arguments: [.literal("\(i)")])
    case .real(let r): .call(.name("real_toString"), arguments: [.literal("\(r)")])
    case .bitfield(let b): .call(.name("bitfield_toString"), arguments: [.literal("\(b)")])
    default: fatalError("toString is not yet supported for \(expression). Should look for a HasStringRepresentation vtable")
    }
}
