import Foundation
import Testing

@Test("Compile and Run C Code", arguments: cInputFiles())
func compile_c_code(file: TestInputFile) async throws {
    let fm = FileManager.default

    let exeFile = file.url.deletingPathExtension()
    try #require(fm.fileExists(atPath: file.url.path()))

    let (compilerOutput, isCompilerError) = try runExecutable(
        atPath: "/usr/bin/clang",
        arguments: [
            file.url.path(),
            "-I", Bundle.target.resourceURL!.appending(component: "headers").path(),
            "-o", exeFile.path(),
        ]
    )

    if let expectedError = file.expectedError {
        #expect(compilerOutput == expectedError)
        #expect(isCompilerError)
    } else if let expectedOutput = file.expectedOutput {
        #expect(!isCompilerError, Comment(rawValue: compilerOutput))
        try #require(fm.fileExists(atPath: file.url.deletingPathExtension().path()))
        let (programOutput, isProgramError) = try runExecutable(atPath: file.url.deletingPathExtension().path(), arguments: [])
        #expect(programOutput == expectedOutput)
        #expect(!isProgramError)
    } else {
        #expect(!isCompilerError, Comment(rawValue: compilerOutput))
    }
}

private func cInputFiles() -> [TestInputFile] {
    let resourceURL = Bundle.module.resourceURL!
    return try! FileManager.default.contentsOfDirectory(at: resourceURL.appending(component: "c-files"), includingPropertiesForKeys: [])
        .filter { $0.pathExtension == "c" }
        .map {
            let name = $0.deletingPathExtension().lastPathComponent
                .replacing("-", with: " ")
                //.replacing(/\b(\w)/) { $0.output.1.uppercased() }
            return TestInputFile(
                description: name,
                url: $0)
            }
}

@Test("Compile and Run Clawr Code", arguments: clawrInputFiles())
func compile_clawr_code(file: TestInputFile) async throws {
    let fm = FileManager.default

    let executablePath = [".build/debug/rwrc", "rwrc"].first { fm.fileExists(atPath: $0) }!
    try #require(fm.fileExists(atPath: file.url.path()))

    let (compilerOutput, isCompilerError) = try runExecutable(
        atPath: executablePath,
        arguments: [file.url.path()]
    )

    if let expectedError = file.expectedError {
        #expect(compilerOutput == expectedError)
        #expect(isCompilerError)
    } else if let expectedOutput = file.expectedOutput {
        #expect(!isCompilerError, Comment(rawValue: compilerOutput))
        try #require(fm.fileExists(atPath: file.url.deletingPathExtension().path()))
        let (programOutput, isProgramError) = try runExecutable(atPath: file.url.deletingPathExtension().path(), arguments: [])
        #expect(programOutput == expectedOutput)
        #expect(!isProgramError)
    } else {
        #expect(!isCompilerError, Comment(rawValue: compilerOutput))
    }
}

private func clawrInputFiles() -> [TestInputFile] {
    let resourceURL = Bundle.module.resourceURL!
    return try! FileManager.default.contentsOfDirectory(at: resourceURL.appending(component: "oo-files"), includingPropertiesForKeys: [])
        .filter { $0.pathExtension == "oo" }
        .map {
            let name = $0.deletingPathExtension().lastPathComponent
                .replacing("-", with: " ")
                //.replacing(/\b(\w)/) { $0.output.1.uppercased() }
            return TestInputFile(
                description: name,
                url: $0)
            }
}

private func runExecutable(atPath path: String, arguments: [String]) throws -> (String, isError: Bool) {
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
    return (output, process.terminationStatus != 0)
}

struct TestInputFile: CustomStringConvertible {
    var description: String
    var url: URL

    var expectedError: String? {
        let errURL = url.deletingPathExtension().appendingPathExtension("err")
        guard FileManager.default.fileExists(atPath: errURL.path()) else { return nil }
        return try! String(contentsOf: errURL, encoding: .utf8)
    }

    var expectedOutput: String? {
        let outURL = url.deletingPathExtension().appendingPathExtension("out")
        guard FileManager.default.fileExists(atPath: outURL.path()) else { return nil }
        return try! String(contentsOf: outURL, encoding: .utf8)
    }
}

private extension Bundle {
    static var target: Bundle {
        let url = Bundle.module.bundleURL
            .deletingLastPathComponent()
            .appending(path: "Clawr_Clawr.bundle")
        return Bundle(url: url)!
    }
}
