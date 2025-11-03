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
            let type: String
            switch variable.type {
            case .builtin(let t): type = t.rawValue
            case .data(let t): type = "\(t.name)*"
            }
            result.append(.variable(variable.name, type: type, initializer: initializer.map(irgen(expression:)) ?? .literal("NULL")))
            if let initializer {
                let assignments = irgen(assigned: initializer, to: .name(variable.name))
                result.append(contentsOf: assignments)
            }
        case .dataStructureDeclaration(let name, fields: let fields):
            result.append(.structDeclaration(
                "__\(name)_data",
                fields: fields.map {
                    Field(type: .simple($0.type.irName), name: $0.name)
                }
            ))
            result.append(.structDeclaration(
                name,
                fields: [
                    Field(type: .simple("struct __oo_rc_header"), name: "header"),
                    Field(type: .simple("struct __\(name)_data"), name: name),
                ]
            ))
            result.append(.variable(
                "__\(name)_data_type",
                type: "__oo_data_type",
                initializer: .structInitializer([
                    NamedValue(name: "size", value: .call(.name("sizeof"), arguments: [.reference(.name(name))]))
                ])
            ))
            result.append(.variable(
                "__\(name)_info",
                type: "__oo_type_info",
                initializer: .structInitializer([
                    NamedValue(name: "data", value: .reference(.address(of: .name("__\(name)_data_type"))))
                ])
            ))
        case .functionDeclaration(let name, returns: let returnType, parameters: let parameters, body: let body):
            result.append(.function(name, returns: returnType?.name ?? "void", parameters: [], body: irgen(statements: body)))
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
    case .real(let r): .literal("\(1/r)")
    case .bitfield(let b): .literal("\(b)")
    case .identifier(let identifier, type: _): .reference(.name(identifier))
    case .memberLookup(let target): irgen(lookup: target)
    case .dataStructureLiteral(let type, fieldValues: _):
        .call(.name("oo_alloc"), arguments: [.reference(.name("__oo_ISOLATED")), .reference(.name("__\(type.name)_info"))])
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
    switch expression {
    case .boolean(let b): .call(.name("boolean_toString"), arguments: [.literal(b ? "1" : "0")])
    case .integer(let i): .call(.name("integer_toString"), arguments: [.literal("\(i)")])
    case .real(let r): .call(.name("real_toString"), arguments: [.literal("\(r)")])
    case .bitfield(let b): .call(.name("bitfield_toString"), arguments: [.literal("\(b)")])
    default: fatalError("toString is not yet supported for \(expression). Should look for a HasStringRepresentation vtable")
    }
}

extension ResolvedType {
    var isPointer: Bool {
        switch self {
        case .builtin(_): false
        case .data(_): true
        }
    }

    var irName: String {
        "\(name)\(isPointer ? "*" : "")"
    }
}
