import AppKit
import Foundation
import Observation
import PureMP3Core

@Observable
@MainActor
final class AppViewModel {
    enum DisplayMode: String, CaseIterable, Identifiable {
        case liquidGlass
        case oled

        var id: String { rawValue }

        var title: String {
            switch self {
            case .liquidGlass:
                "Glass"
            case .oled:
                "OLED"
            }
        }
    }

    var selectedPreset: AudioQualityPreset = .vbrBalanced
    var displayMode: DisplayMode = .oled
    var jobs: [ConversionJob] = []
    var outputDirectory: URL = FileManager.default.urls(for: .musicDirectory, in: .userDomainMask).first
        ?? FileManager.default.homeDirectoryForCurrentUser
    var isConverting = false
    var globalMessage: String?

    private let commandBuilder = FFmpegCommandBuilder()
    private let ffmpeg = ShellFFmpegClient()

    var commandPreview: String {
        guard let firstJob = jobs.first else {
            return "ffmpeg -i input.mp4 -vn -codec:a libmp3lame -q:a 2 output.mp3"
        }

        return commandBuilder.shellPreview(
            inputURL: firstJob.inputURL,
            outputURL: firstJob.outputURL,
            preset: selectedPreset,
            overwrite: true
        )
    }

    var hasJobs: Bool {
        !jobs.isEmpty
    }

    func addFiles(_ urls: [URL]) {
        let supportedURLs = urls.filter { !$0.hasDirectoryPath }
        let newJobs = supportedURLs.map { url in
            ConversionJob(
                inputURL: url,
                outputURL: outputURL(for: url)
            )
        }

        jobs.append(contentsOf: newJobs)
        globalMessage = newJobs.isEmpty ? "No supported files were added." : nil

        Task {
            await loadMediaInfo(for: newJobs.map(\.id))
        }
    }

    func chooseFiles() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.movie, .audio, .mpeg4Movie, .mp3]

        if panel.runModal() == .OK {
            addFiles(panel.urls)
        }
    }

    func chooseOutputDirectory() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = false
        panel.canChooseDirectories = true

        if panel.runModal() == .OK, let url = panel.url {
            outputDirectory = url
            jobs = jobs.map { job in
                var updatedJob = job
                updatedJob.outputURL = outputURL(for: job.inputURL)
                return updatedJob
            }
        }
    }

    func removeJobs(at offsets: IndexSet) {
        jobs.remove(atOffsets: offsets)
    }

    func clearCompleted() {
        jobs.removeAll {
            if case .completed = $0.state {
                true
            } else {
                false
            }
        }
    }

    func convertAll() {
        guard !isConverting else { return }

        isConverting = true
        globalMessage = nil

        Task {
            for jobID in jobs.map(\.id) {
                guard let index = jobs.firstIndex(where: { $0.id == jobID }) else { continue }
                jobs[index].state = .running(progress: nil)

                let arguments = commandBuilder.arguments(
                    inputURL: jobs[index].inputURL,
                    outputURL: jobs[index].outputURL,
                    preset: selectedPreset,
                    overwrite: true
                )

                do {
                    try await ffmpeg.run(arguments: arguments)
                    jobs[index].state = .completed(outputURL: jobs[index].outputURL)
                } catch {
                    jobs[index].state = .failed(message: error.localizedDescription)
                }
            }

            isConverting = false
        }
    }

    func revealOutput(for job: ConversionJob) {
        NSWorkspace.shared.activateFileViewerSelecting([job.outputURL])
    }

    private func outputURL(for inputURL: URL) -> URL {
        outputDirectory
            .appendingPathComponent(inputURL.deletingPathExtension().lastPathComponent)
            .appendingPathExtension("mp3")
    }

    private func loadMediaInfo(for jobIDs: [UUID]) async {
        for jobID in jobIDs {
            guard let index = jobs.firstIndex(where: { $0.id == jobID }) else { continue }

            do {
                let data = try await ffmpeg.probe(url: jobs[index].inputURL)
                jobs[index].mediaInfo = try FFprobeParser.parseMediaInfo(from: data)
            } catch {
                continue
            }
        }
    }
}
