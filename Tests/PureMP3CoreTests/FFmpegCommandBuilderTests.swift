import Foundation
import Testing
@testable import PureMP3Core

@Suite
struct FFmpegCommandBuilderTests {
    @Test
    func buildsLosslessUltraCommand() {
        let builder = FFmpegCommandBuilder()
        let arguments = builder.arguments(
            inputURL: URL(fileURLWithPath: "/tmp/input.wav"),
            outputURL: URL(fileURLWithPath: "/tmp/output.flac"),
            preset: .losslessUltra,
            overwrite: true
        )

        #expect(arguments == [
            "-y",
            "-i", "/tmp/input.wav",
            "-vn",
            "-codec:a", "flac",
            "-compression_level", "12",
            "/tmp/output.flac"
        ])
    }

    @Test
    func buildsVBRBestCommand() {
        let builder = FFmpegCommandBuilder()
        let arguments = builder.arguments(
            inputURL: URL(fileURLWithPath: "/tmp/input.mp4"),
            outputURL: URL(fileURLWithPath: "/tmp/output.mp3"),
            preset: .vbrBest,
            overwrite: true
        )

        #expect(arguments == [
            "-y",
            "-i", "/tmp/input.mp4",
            "-vn",
            "-codec:a", "libmp3lame",
            "-q:a", "0",
            "/tmp/output.mp3"
        ])
    }

    @Test
    func buildsFixedBitrateCommand() {
        let builder = FFmpegCommandBuilder()
        let arguments = builder.arguments(
            inputURL: URL(fileURLWithPath: "/tmp/input.mp4"),
            outputURL: URL(fileURLWithPath: "/tmp/output.mp3"),
            preset: .cbr320
        )

        #expect(arguments.contains("-n"))
        #expect(arguments.contains("320k"))
    }

    @Test
    func previewsShellEscapedPaths() {
        let builder = FFmpegCommandBuilder()
        let preview = builder.shellPreview(
            inputURL: URL(fileURLWithPath: "/tmp/my file.mp4"),
            outputURL: URL(fileURLWithPath: "/tmp/my file.mp3"),
            preset: .vbrBalanced
        )

        #expect(preview.contains("'/tmp/my file.mp4'"))
        #expect(preview.contains("'/tmp/my file.mp3'"))
    }
}
