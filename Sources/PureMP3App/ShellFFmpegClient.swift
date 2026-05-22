import Foundation

enum ShellFFmpegError: LocalizedError {
    case missingExecutable(String)
    case processFailed(command: String, output: String)

    var errorDescription: String? {
        switch self {
        case .missingExecutable(let name):
            "\(name) was not found. Install FFmpeg with Homebrew: brew install ffmpeg"
        case .processFailed(let command, let output):
            "Command failed: \(command)\n\(output)"
        }
    }
}

struct ShellFFmpegClient {
    func run(arguments: [String]) async throws {
        _ = try await execute("ffmpeg", arguments: arguments)
    }

    func probe(url: URL) async throws -> Data {
        try await execute(
            "ffprobe",
            arguments: [
                "-v", "error",
                "-show_entries", "format=duration,bit_rate",
                "-show_streams",
                "-of", "json",
                url.path
            ]
        )
    }

    private func execute(_ executableName: String, arguments: [String]) async throws -> Data {
        let executableURL = try findExecutable(named: executableName)

        return try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = executableURL
            process.arguments = arguments

            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = errorPipe

            process.terminationHandler = { process in
                let output = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let errorOutput = errorPipe.fileHandleForReading.readDataToEndOfFile()

                if process.terminationStatus == 0 {
                    continuation.resume(returning: output)
                } else {
                    let message = String(data: errorOutput + output, encoding: .utf8) ?? ""
                    continuation.resume(
                        throwing: ShellFFmpegError.processFailed(
                            command: ([executableName] + arguments).joined(separator: " "),
                            output: message
                        )
                    )
                }
            }

            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func findExecutable(named name: String) throws -> URL {
        let candidates = [
            "/opt/homebrew/bin/\(name)",
            "/usr/local/bin/\(name)",
            "/usr/bin/\(name)"
        ]

        if let path = candidates.first(where: { FileManager.default.isExecutableFile(atPath: $0) }) {
            return URL(fileURLWithPath: path)
        }

        throw ShellFFmpegError.missingExecutable(name)
    }
}
