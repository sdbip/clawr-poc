import Testing
import Parser

@Suite("Scope")
struct ScopeTests {

    @Test
    func resolves_registered_variable_declaration() async throws {
        let scope = Scope()
        let variable = Variable(name: "x", semantics: .immutable, type: .builtin(.bitfield))
        scope.register(variable: variable)
        #expect(scope.variable(forName: "x") == variable)
    }

    @Test
    func resolves_variable_declaration_in_parent_scope() async throws {
        let parent = Scope()
        let variable = Variable(name: "x", semantics: .immutable, type: .builtin(.bitfield))
        parent.register(variable: variable)

        let scope = Scope(parent: parent, parameters: [])
        #expect(scope.variable(forName: "x") == variable)
    }
}
