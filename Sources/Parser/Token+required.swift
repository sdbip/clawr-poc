import Lexer

extension Optional where Wrapped == Token {
    func required() throws -> Token {
        guard let self else { throw ParserError.unexpectedEOF }
        return self
    }

    func requiring(_ isGood: (Token) -> Bool) throws -> Token {
        let token = try required()
        return try token.requiring(isGood)
    }
}

extension Token {
    func requiring(_ isGood: (Token) -> Bool) throws -> Token {
        guard isGood(self) else { throw ParserError.invalidToken(self) }
        return self
    }
}
