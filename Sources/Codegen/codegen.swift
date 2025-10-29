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
    }
}
