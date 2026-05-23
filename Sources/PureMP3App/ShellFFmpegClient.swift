import Foundation

enum ShellFFmpegError: LocalizedError {
    case missingExecutable(String)
    case processFailed(command: String, output: String)

    var errorDescription: String? {
        switch self {
        case .missingExecutable(let name):
            "PureMP3 could not find \(name). Reinstall the app, or use a development build with FFmpeg available."
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
            process.environment = processEnvironment(for: executableURL)

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
        let fileManager = FileManager.default
        let candidates = bundledExecutableCandidates(named: name) + developerExecutableCandidates(named: name)

        if let path = candidates.first(where: { fileManager.isExecutableFile(atPath: $0) }) {
            return URL(fileURLWithPath: path)
        }

        throw ShellFFmpegError.missingExecutable(name)
    }

    private func bundledExecutableCandidates(named name: String) -> [String] {
        var candidates: [String] = []

        if let resourceURL = Bundle.main.resourceURL {
            candidates.append(
                resourceURL
                    .appendingPathComponent("FFmpeg")
                    .appendingPathComponent("bin")
                    .appendingPathComponent(name)
                    .path
            )
        }

        candidates.append(
            Bundle.main.bundleURL
                .appendingPathComponent("Contents")
                .appendingPathComponent("Resources")
                .appendingPathComponent("FFmpeg")
                .appendingPathComponent("bin")
                .appendingPathComponent(name)
                .path
        )

        return candidates
    }

    private func developerExecutableCandidates(named name: String) -> [String] {
        var candidates: [String] = []

        if let overrideDirectory = ProcessInfo.processInfo.environment["PUREMP3_FFMPEG_DIR"], !overrideDirectory.isEmpty {
            candidates.append(URL(fileURLWithPath: overrideDirectory).appendingPathComponent(name).path)
        }

        candidates.append(contentsOf: [
            "/opt/homebrew/bin/\(name)",
            "/usr/local/bin/\(name)",
            "/usr/bin/\(name)"
        ])

        return candidates
    }

    private func processEnvironment(for executableURL: URL) -> [String: String] {
        var environment = ProcessInfo.processInfo.environment
        let bundledLibraryURL = executableURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("lib")

        guard FileManager.default.fileExists(atPath: bundledLibraryURL.path) else {
            return environment
        }

        let existingPath = environment["DYLD_LIBRARY_PATH"]
        environment["DYLD_LIBRARY_PATH"] = [bundledLibraryURL.path, existingPath]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ":")

        return environment
    }
}
