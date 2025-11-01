import Lexer

protocol StatementParseable {
    static func isNext(in stream: TokenStream) -> Bool
    init(parsing stream: TokenStream, in scope: Scope) throws
    func resolve() throws -> Statement
}
