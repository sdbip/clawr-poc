import Foundation
import Lexer
import Parser
import Codegen
import IRGen

let headersDirectoryURL = Bundle.module.resourceURL!.appending(path: "headers", directoryHint: .isDirectory)
guard FileManager.default.fileExists(atPath: headersDirectoryURL.appending(path: "oo-stdlib.h", directoryHint: .notDirectory).path) else {
    fatalError("oo-stdlib.h not found in resource bundle")
}

// azc <path-to-source.az>
guard CommandLine.arguments.count > 1 else {
    fputs("Usage: ooc <path/to/source.oo>\n\n", stderr)
    exit(2)
}

let inputFile = URL(fileURLWithPath: CommandLine.arguments[1])
let cFile = inputFile.deletingPathExtension().appendingPathExtension("c").path
let exeFile = inputFile.deletingPathExtension().path

let source = try String(contentsOf: inputFile, encoding: .utf8)

do {
    let ast = try parse(source)
    // TODO: Optimize AST
    let ir = irgen(ast: ast)
    // TODO: Optimize IR
    let code = codegen(ir: ir)

    try code.write(toFile: cFile, atomically: true, encoding: .utf8)

} catch let error as ParserError {
    switch error {
    case .unexpectedEOF:
        fputs("\(inputFile.lastPathComponent):Unexpected end of file\n", stderr)
    case .invalidToken(let token):
        fputs("\(inputFile.lastPathComponent):\(token.location.line):\(token.location.column):Invalid token \(token.value) (\(token.kind.rawValue))\n", stderr)
    case .unresolvedType(let location):
        fputs("\(inputFile.lastPathComponent):\(location.line):\(location.column):Unresolved type\n", stderr)
    case .typeMismatch(declared: let declared, inferred: let inferred, location: let location):
        fputs("\(inputFile.lastPathComponent):\(location.line):\(location.column):Type mismatch; expected: \(declared), was: (\(inferred)\n", stderr)
    case .unknownVariable(let name, let location):
        fputs("\(inputFile.lastPathComponent):\(location.line):\(location.column):Unknown variable: \(name)\n", stderr)
    case .unknownFunction(let name, let location):
        fputs("\(inputFile.lastPathComponent):\(location.line):\(location.column):Unknown function: \(name)\n", stderr)
}
    exit(2)
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/clang")
process.arguments = [cFile, "-I", headersDirectoryURL.path, "-o", exeFile]

let pipe = Pipe()
process.standardOutput = pipe
process.standardError = pipe

try process.run()
process.waitUntilExit()

let data = try pipe.fileHandleForReading.readToEnd() ?? Data()
if process.terminationStatus != 0 {
    let output = String(decoding: data, as: UTF8.self)
    fputs(output, stderr)
    exit(process.terminationStatus)
}
