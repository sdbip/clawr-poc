public func codegen(ir: [Statement]) -> String {
    return """
        #include "oo-stdlib.h"
        #include "oo-runtime.h"

        \(
            ir.map(codegen(statement:))
                .joined(separator: "\n")
        )
        """
}

public func codegen(statement: Statement) -> String {
    switch statement {
    case .structDeclaration(let name, fields: let fields):
        return """
            typedef struct \(name) {
                \( fields.map(codegen(field:)).joined(separator: ";") );
            } \(name);
            """
    case .variable(let name, type: let type, initializer: let initializer):
        return "\(type) \(name) = \(codegen(expression: initializer));"
    case .assign(let reference, value: let value):
        return "\(codegen(expression: .reference(reference))) = \(codegen(expression: value));"
    case .function(let name, returns: let type, parameters: let parameters, body: let body):
        return """
            \(type) \(name) (\( parameters.map(codegen(field:)).joined(separator: ",") )) {
                \(body.map(codegen(statement:)).joined(separator: "\n"))
            }
            """
    case .call(let reference, arguments: let arguments):
        return "\(codegen(expression: .reference(reference)))(\(arguments.map(codegen(expression:)).joined(separator: ",")));"
    case .return(let expr):
        return "return \(codegen(expression: expr));"
    }
}

func codegen(expression: Expression) -> String {
    switch expression {
    case .structInitializer(let fields):
        return """
            {
            \(fields.map {
                ".\($0.name) = \(codegen(expression: $0.value)),"
            }.joined())
            }
            """
    case .arrayInitializer(let values):
        return "(void*[]) {\( values.map(codegen(expression:)).joined(separator: ",") )}"
    case .literal(let s): return s
    case .reference(.address(of: let reference)):
        return "&\(codegen(expression: .reference(reference)))"
    case .cast(let expression, type: let type):
        return "/(\(type))\(codegen(expression: expression)))"
    case .reference(.cast(let reference, type: let type)):
        return "((\(type))\(codegen(expression: .reference(reference))))"
    case .reference(.name(let name)):
        return "\(name)"
    case .reference(.field(target: let reference, name: let name, isPointer: let isPointer)):
        return "\(codegen(expression: .reference(reference)))\(isPointer ? "->" : ".")\(name)"
    case .call(let reference, arguments: let arguments):
        return "\(codegen(expression: .reference(reference)))(\(arguments.map(codegen(expression:)).joined(separator: ",")))"
    }
}

func codegen(field: Field) -> String {
    switch field.type {
    case .simple(let t): "\(t) \(field.name)"
    case .function(returnType: let returnType, parameters: let parameters):
        "\(returnType) (*\(field.name))(\(parameters.joined(separator: ",")))"
    }
}
