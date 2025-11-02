import Lexer

extension Optional where Wrapped == Token {
    func required() throws -> Token {
        guard let self else { throw ParserError.unexpectedEOF }
        return self
    }

    func requiring(_ isGood: (Token) -> Bool) throws -> Token {
        let token = try required()
        guard isGood(token) else { throw ParserError.invalidToken(token) }
        return token
    }
}
