public struct FileLocation: Equatable, Sendable {
    public var line: UInt
    public var column: UInt

    public init(line: UInt, column: UInt) {
        self.line = line
        self.column = column
    }
}
