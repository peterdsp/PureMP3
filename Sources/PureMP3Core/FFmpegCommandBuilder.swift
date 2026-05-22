import Foundation

public struct FFmpegCommandBuilder: Sendable {
    public init() {}

    public func arguments(
        inputURL: URL,
        outputURL: URL,
        preset: AudioQualityPreset,
        overwrite: Bool = false
    ) -> [String] {
        var arguments: [String] = []
        arguments.append(overwrite ? "-y" : "-n")
        arguments.append(contentsOf: ["-i", inputURL.path])
        arguments.append(contentsOf: preset.ffmpegArguments)
        arguments.append(outputURL.path)
        return arguments
    }

    public func shellPreview(
        inputURL: URL,
        outputURL: URL,
        preset: AudioQualityPreset,
        overwrite: Bool = false
    ) -> String {
        let escapedArguments = arguments(
            inputURL: inputURL,
            outputURL: outputURL,
            preset: preset,
            overwrite: overwrite
        )
        .map { $0.shellEscaped }
        .joined(separator: " ")

        return "ffmpeg \(escapedArguments)"
    }
}

private extension String {
    var shellEscaped: String {
        if allSatisfy({ $0.isLetter || $0.isNumber || "-_./:".contains($0) }) {
            return self
        }

        return "'\(replacingOccurrences(of: "'", with: "'\\''"))'"
    }
}
