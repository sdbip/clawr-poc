public func codegen(ir: IR) -> String {
    switch ir {
    case .data(name: let name, fields: let fields):
        return """
            struct __\(name)_data { \( fields.map { "\($0.type) \($0.name);" }.joined()) };
            typedef struct \(name) {
                struct __oo_rc_header header;
                struct __\(name)_data \(name)Data;
            } \(name);
            """
    case .traitDeclaration(name: let name, methods: let methods):
        return """
            typedef struct \(name)_vtable {
                \(methods.map {
                    "\($0.returnType) (*\($0.name))(\($0.parameters.map { "\($0.type) \($0.name)" }.joined(separator: ", ")));"
                }.joined(separator: "\n    "))
            } \(name)_vtable;
            static const __oo_trait_descriptor \(name)_trait = { .name = "\(name)" };
            """
    case .traitImplementations(target: let target, traits: let traits):
        return """
            \(traits.map { """
                \($0.name)_vtable \(target)_\($0.name)_vtable = {
                    \($0.methods.map {
                        ".\($0) = \(target)_\($0)"
                    }.joined(separator: "\n    "))
                };
                """ }.joined(separator: "\n"))

            __oo_data_type __\(target)_data_type = {
                .size = sizeof(\(target)),
                .trait_descs = (__oo_trait_descriptor*[]) { \( traits.map { "&\($0.name)_trait" }.joined(separator: ", ") ) },
                .trait_vtables = (void*[]) { \( traits.map { "&\(target)_\($0.name)_vtable" }.joined(separator: ", ") ) },
                .trait_count = 1
            };
            __oo_type_info __\(target)_info = { .data = &__\(target)_data_type };
            """
    }
}
