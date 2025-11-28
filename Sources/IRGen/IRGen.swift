import Parser
import Codegen

nonisolated(unsafe) private var __emittedDataStructures = Set<String>()

public func irgen(ast: [Parser.Statement]) -> [Codegen.Statement] {
    let statements = irgen(statements: ast)
    var functions = statements.filter {
        switch $0 {
        case .function: true
        default: false
        }
    }

    let nonFunctions = statements.filter {
        switch $0 {
        case .function: false
        default: true
        }
    }

    functions.append(.function(
        "main",
        returns: "int",
        parameters: [],
        body: nonFunctions
    ))

    return functions
}

public func irgen(statements: [Parser.Statement]) -> [Codegen.Statement] {
    return statements.flatMap(irgen(statement:))
}

public func irgen(statement: Parser.Statement) -> [Codegen.Statement] {
    var result: [Codegen.Statement] = []

    switch statement {
    case .variableDeclaration(let variable):
        result.append(.variable(variable.name, type: variable.type.irName, initializer: variable.initialValue.map(irgen(expression:)) ?? .literal("NULL")))
        if case .dataStructureLiteral(_, fieldValues: let fields) = variable.initialValue {
            result.append(contentsOf: irgen(assignFields: fields, to: .name(variable.name)))
        }
    case .objectDeclaration(let object):
        // An object is essentially a data structure, but it is hidden behind encapsulation
        result.append(
            contentsOf: irgen(statement: .dataStructureDeclaration(DataStructure(
                name: object.name,
                fields: object.fields,
                companion: object.companion
            )))
        )
        // TODO: Add methods and factories
    case .dataStructureDeclaration(let dataStructure):
        // Skip if we already emitted this structure
        if __emittedDataStructures.contains(dataStructure.name) {
            return []
        }
        __emittedDataStructures.insert(dataStructure.name)

        // Emit nested data structures first; rely on the global set for de-dup
        for field in dataStructure.fields {
            if case .data(let nested) = field.type {
                result.append(contentsOf: irgen(statement: .dataStructureDeclaration(nested)))
            }
        }

        // Now emit this data structure and its metadata (unchanged below)
        if let companion = dataStructure.companion {
            result.append(.structDeclaration(
                "__\(dataStructure.name)_static",
                fields: companion.fields.map {
                    Field(type: .simple($0.type.irName), name: $0.name)
                }
            ))
            result.append(.variable(
                companion.name,
                type: "__\(dataStructure.name)_static",
                initializer: .structInitializer(companion.fields.map {
                    NamedValue(name: $0.name, value: irgen(expression: $0.initialValue ?? .integer(0)))
                })
            ))

            for method in companion.methods {
                result.append(.function(
                    "\(companion.name)_$$_\(method.name)\(method.parameters.map { "_\($0.label ?? "")" }.joined())",
                    returns: method.returnType?.irName ?? "void",
                    parameters: method.parameters.map {
                        Field(type: .simple($0.value.type.irName), name: $0.value.name)
                    },
                    body: method.body.map {
                        switch $0 {
                        case .variableDeclaration(let variable):
                            return .variable(variable.name, type: variable.type.irName, initializer: irgen(expression: variable.initialValue ?? .integer(0)))
                        case .returnStatement(let expr):
                            return .return(irgen(expression: expr))
                        default:
                            fatalError("Unable to codify \($0)")
                        }
                    }
                ))
            }
        }

        result.append(.structDeclaration(
            dataStructure.name,
            fields: [
                Field(type: .simple("__clawr_rc_header"), name: "header"),
            ] + dataStructure.fields.map {
                Field(type: .simple($0.type.irName), name: $0.name)
            }

        ))
        result.append(.variable(
            "__\(dataStructure.name)_info",
            type: "__clawr_type_info",
            initializer: .structInitializer([
                NamedValue(name: "size", value: .call(.name("sizeof"), arguments: [.reference(.name(dataStructure.name))]))
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
    }
    return result
}

func irgen(assigned expression: Parser.Expression, to target: Reference) -> [Codegen.Statement] {
    var result: [Codegen.Statement] = []
    result.append(.assign(target, value: irgen(expression: expression)))

    if case .dataStructureLiteral(_, fieldValues: let values) = expression {
        result.append(contentsOf: irgen(assignFields: values, to: target))
    }

    return result
}

func irgen(assignFields values: [String : Parser.Expression], to target: Reference) -> [Codegen.Statement] {
    var result: [Codegen.Statement] = []
    for (fieldName, value) in values {
        let assignments = irgen(
            assigned: value,
            to: .field(
                target: .reference(target),
                name: fieldName,
                isPointer: true
            )
        )
        result.append(contentsOf: assignments)
    }
    return result
}

func irgen(expression: Parser.Expression) -> Codegen.Expression {
    switch expression {
    case .boolean(let b): return .literal(b ? "1" : "0")
    case .integer(let i): return .literal("\(i)")
    case .real(let r): return .literal("\(r)")
    case .bitfield(let b): return .literal("0x\(String(b, radix: 16))")
    case .identifier(let identifier, type: let type):
        if case .companionObject(_) = type {
            return .reference(.name("\(identifier)_static"))
        } else {
            return .reference(.name(identifier))
        }
    case .memberLookup(let target, member: let member, type: _):
        if target.type.isPointer {
            return .reference(.field(
                target: irgen(expression: target),
                name: member,
                isPointer: true
            ))
        } else {
            return .reference(.field(
                target: irgen(expression: target),
                name: member,
                isPointer: false
            ))
        }
    case .functionCall(_, arguments: _, type: _): fatalError("Function call not yet implemented")
    case .methodCall(let name, target: let target, arguments: let arguments, _):
        switch target.type {
        case .companionObject(let object):
            return .call(
                .name("\(object.name)_$$_\(name)\(arguments.map { "_\($0.label ?? "")" }.joined())"),
                arguments: arguments.map { irgen(expression: $0.value) }
            )
        //case .object(let object):
        default: fatalError("Calling methods from \(target.type) in unsupported")
        }
    case .dataStructureLiteral(let type, fieldValues: _):
        return .call(.name("allocRC"), arguments: [.reference(.address(of: .name(("__\(type.name)_info")))), .reference(.name("__clawr_ISOLATED"))])
    case .unaryOperation(operator: let op, expression: let expression): fatalError("Operators not yet implemented")
    case .binaryOperation(left: let left, operator: .leftShift, right: let right):
        return .call(.name("leftShift"), arguments: [irgen(expression: left), irgen(expression: right)])
    case .binaryOperation(left: let left, operator: let op, right: let right): fatalError("Operators not yet implemented")
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
        case .companionObject(_): false
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
