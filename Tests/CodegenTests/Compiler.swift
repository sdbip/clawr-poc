import Foundation
import Codegen

func run(ir: [Statement], testName name: String = #function) throws -> String {

    let cFileURL = debugDir.appending(component: "\(name.replacing("()", with: "")).c")
    let cFile = cFileURL.path()
    let exeFile = cFileURL.deletingPathExtension().path()

    try """
    #pragma GCC diagnostic ignored "-Wincompatible-pointer-types-discards-qualifiers"
    #pragma GCC diagnostic ignored "-Wincompatible-function-pointer-types"
    #pragma GCC diagnostic ignored "-Wincompatible-pointer-types"
    \(codegen(ir: ir))
    """
        .write(toFile: cFile, atomically: true, encoding: .utf8)

    try compile(cFile: cFile, to:exeFile)
    return try runExecutable(atPath: exeFile, arguments: [])
}

private func compile(cFile: String, to exeFile: String) throws {
    _ = try runExecutable(
        atPath: "/usr/bin/clang",
        arguments: [
            cFile,
            "-I", headersDir,
            "-o", exeFile,
        ]
    )
}

enum CompilerError: Error {
    case message(String)
}

private func runExecutable(atPath path: String, arguments: [String]) throws -> String {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: path)
    process.arguments = arguments

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    try process.run()
    process.waitUntilExit()

    let data = try pipe.fileHandleForReading.readToEnd() ?? Data()
    let output = String(decoding: data, as: UTF8.self)
    guard process.terminationStatus == 0 else { throw CompilerError.message(output) }
    return output
}

private let debugDir = Bundle(for: X.self).bundleURL.deletingLastPathComponent()
private let oolangBundle = Bundle(url: debugDir.appending(path: "Oolang_Oolang.bundle"))!
private let headersDir = oolangBundle.resourceURL!.appending(component: "headers").path()

class X {}
