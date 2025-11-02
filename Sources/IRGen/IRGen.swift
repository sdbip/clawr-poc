import Parser
import Codegen

public func irgen(ast: [Parser.Statement]) -> [Codegen.Statement] {
    var functions = irgen(statements: ast.filter {
        switch $0 {
        case .functionDeclaration(_, returns: _, parameters: _, body: _): true
        default: false
        }
    })

    let nonFunctions = irgen(statements: ast.filter {
        switch $0 {
        case .functionDeclaration(_, returns: _, parameters: _, body: _): false
        default: true
        }
    })

    functions.append(.function(
        "main",
        returns: "int",
        parameters: [],
        body: nonFunctions
    ))

    return functions
}

public func irgen(statements: [Parser.Statement]) -> [Codegen.Statement] {
    var result: [Codegen.Statement] = []
    for statement in statements {
        switch statement {
        case .variableDeclaration(let variable, initializer: let initializer):
            result.append(.variable(variable.name, type: variable.type.rawValue, initializer: initializer.map(irgen(expression:)) ?? .literal("NULL")))
        case .dataStructureDeclaration(_, fields: _):
            fatalError("dataStructureDclaration not yet implemented!!")
        case .functionDeclaration(let name, returns: let returnType, parameters: let parameters, body: let body):
            result.append(.function(name, returns: returnType?.rawValue ?? "void", parameters: [], body: irgen(statements: body)))
        case .functionCall(let name, arguments: let arguments):
            result.append(.call(.name(name), arguments: []))
        case .printStatement(let expression):
            result.append(.call(.name("print"), arguments: [toString(expression: expression)]))
        case .returnStatement(let expression):
            result.append(.return(irgen(expression: expression)))
        }
    }

    return result
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
