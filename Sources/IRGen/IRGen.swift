import Parser
import Codegen

public func irgen(ast: [Parser.Statement]) -> [Codegen.Statement] {
    var functions = irgen(statements: ast.filter {
        switch $0 {
        case .functionDeclaration(_): true
        default: false
        }
    })

    let nonFunctions = irgen(statements: ast.filter {
        switch $0 {
        case .functionDeclaration(_): false
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
            result.append(.variable(variable.name, type: variable.type.irName, initializer: initializer.map(irgen(expression:)) ?? .literal("NULL")))
            if let initializer {
                let assignments = irgen(assigned: initializer, to: .name(variable.name))
                result.append(contentsOf: assignments)
            }
        case .dataStructureDeclaration(let dataStructure):
            result.append(.structDeclaration(
                "__\(dataStructure.name)_data",
                fields: dataStructure.fields.map {
                    Field(type: .simple($0.type.irName), name: $0.name)
                }
            ))
            result.append(.structDeclaration(
                dataStructure.name,
                fields: [
                    Field(type: .simple("struct __oo_rc_header"), name: "header"),
                    Field(type: .simple("struct __\(dataStructure.name)_data"), name: dataStructure.name),
                ]
            ))
            result.append(.variable(
                "__\(dataStructure.name)_data_type",
                type: "__oo_data_type",
                initializer: .structInitializer([
                    NamedValue(name: "size", value: .call(.name("sizeof"), arguments: [.reference(.name(dataStructure.name))]))
                ])
            ))
            result.append(.variable(
                "__\(dataStructure.name)_info",
                type: "__oo_type_info",
                initializer: .structInitializer([
                    NamedValue(name: "data", value: .reference(.address(of: .name("__\(dataStructure.name)_data_type"))))
                ])
            ))
        case .functionDeclaration(let function):
            result.append(.function(
                resolvedFunctionName(function),
                returns: function.returnType?.name ?? "void",
                parameters: function.parameters.map { Field(type: .simple($0.value.type.irName), name: $0.value.name) },
                body: irgen(statements: function.body)
            ))
        case .functionCall(let name, arguments: let arguments):
            result.append(.call(
                .name(resolvedFunctionName(name, labels: arguments.map { $0.label })),
                arguments: arguments.map { irgen(expression: $0.value) }
            ))
        case .printStatement(let expression):
            result.append(.call(.name("print"), arguments: [toString(expression: expression)]))
        case .returnStatement(let expression):
            result.append(.return(irgen(expression: expression)))
        case .objectDeclaration(_):
            #warning("Object not yet supported")
            fatalError("Object not yet supported")
        }
    }

    return result
}

func irgen(assigned expression: Parser.Expression, to target: Reference) -> [Codegen.Statement] {
    var result: [Codegen.Statement] = []
    result.append(.assign(target, value: irgen(expression: expression)))

    if case .dataStructureLiteral(.data(let type), fieldValues: let values) = expression {
        for (fieldName, value) in values {
            let assignments = irgen(
                assigned: value,
                to: .field(
                    target: .reference(.field(
                        target: .reference(target),
                        name: type.name,
                        isPointer: true
                    )),
                    name: fieldName,
                    isPointer: false
                )
            )
            result.append(contentsOf: assignments)
        }
    }
    return result
}

func irgen(expression: Parser.Expression) -> Codegen.Expression {
    switch expression {
    case .boolean(let b): .literal(b ? "1" : "0")
    case .integer(let i): .literal("\(i)")
    case .real(let r): .literal("\(r)")
    case .bitfield(let b): .literal("\(b)")
    case .identifier(let identifier, type: _): .reference(.name(identifier))
    case .memberLookup(let target): irgen(lookup: target)
    case .dataStructureLiteral(let type, fieldValues: _):
        .call(.name("oo_alloc"), arguments: [.reference(.name("__oo_ISOLATED")), .reference(.name("__\(type.name)_info"))])
    case .unaryOperation(operator: let op, expression: let expression): fatalError("Operators not yet implemented")
    case .binaryOperation(left: let left, operator: let op, right: let right): fatalError("Operators not yet implemented")
    }
}

func irgen(lookup: LookupTarget) -> Codegen.Expression {
    switch lookup {
    case .expression(let expression): irgen(expression: expression)
    case .member(let target, member: let member, type: _):
        .reference(.field(
            target: irgen(lookup: target),
            name: member,
            isPointer: target.type.isPointer
        ))
    }
}

func toString(expression: Parser.Expression) -> Codegen.Expression {
    switch expression.type {
    case .builtin(.boolean): .call(.name("boolean_toString"), arguments: [irgen(expression: expression)])
    case .builtin(.integer): .call(.name("integer_toString"), arguments: [irgen(expression: expression)])
    case .builtin(.real): .call(.name("real_toString"), arguments: [irgen(expression: expression)])
    case .builtin(.bitfield): .call(.name("bitfield_toString"), arguments: [irgen(expression: expression)])
    default: fatalError("toString is not yet supported for \(expression). Should look for a HasStringRepresentation vtable")
    }
}

extension ResolvedType {
    var isPointer: Bool {
        switch self {
        case .builtin(_): false
        case .data(_): true
        case .object(_): true
        }
    }

    var irName: String {
        "\(name)\(isPointer ? "*" : "")"
    }
}

func resolvedFunctionName(_ function: Parser.Function) -> String {
    return resolvedFunctionName(function.name, labels: function.parameters.map(\.label))
}

func resolvedFunctionName(_ name: String, labels: [String?]) -> String {
    return "\(name)__\(labels.map { $0 ?? "_" }.joined(separator: "_"))"
}
