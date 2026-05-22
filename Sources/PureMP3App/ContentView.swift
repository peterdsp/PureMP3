import PureMP3Core
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Bindable var viewModel: AppViewModel
    @State private var isDropTargeted = false

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            HStack(spacing: 0) {
                sidebar
                Divider()
                queue
            }
            Divider()
            footer
        }
        .frame(width: 980, height: 640)
        .background(Color(nsColor: .windowBackgroundColor))
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            handleDrop(providers)
        }
        .overlay {
            if isDropTargeted {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor, lineWidth: 2)
                    .padding(10)
                    .allowsHitTesting(false)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("PureMP3")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                Text("Honest MP3 conversion for people tired of terminal commands.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                viewModel.chooseFiles()
            } label: {
                Label("Add files", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)

            Button {
                viewModel.convertAll()
            } label: {
                Label(viewModel.isConverting ? "Converting" : "Convert", systemImage: "waveform")
            }
            .disabled(!viewModel.hasJobs || viewModel.isConverting)
            .keyboardShortcut(.return, modifiers: .command)
        }
        .padding(20)
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle("Quality")

                ForEach(AudioQualityPreset.allCases) { preset in
                    PresetRow(
                        preset: preset,
                        isSelected: viewModel.selectedPreset == preset
                    ) {
                        viewModel.selectedPreset = preset
                    }
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                SectionTitle("Output")

                Button {
                    viewModel.chooseOutputDirectory()
                } label: {
                    HStack {
                        Image(systemName: "folder")
                        Text(viewModel.outputDirectory.lastPathComponent)
                            .lineLimit(1)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .padding(10)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                SectionTitle("Truth")
                Text(TruthCopy.bitrateTruth)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(18)
        .frame(width: 300)
    }

    private var queue: some View {
        VStack(spacing: 0) {
            if viewModel.jobs.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(viewModel.jobs) { job in
                        JobRow(job: job) {
                            viewModel.revealOutput(for: job)
                        }
                    }
                    .onDelete(perform: viewModel.removeJobs)
                }
                .listStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "arrow.down.doc")
                .font(.system(size: 42, weight: .regular))
                .foregroundStyle(.secondary)

            Text("Drop audio or video files")
                .font(.title3.weight(.semibold))

            Text("MP4, M4A, WAV, FLAC, and existing MP3 files are accepted.")
                .font(.callout)
                .foregroundStyle(.secondary)

            Button {
                viewModel.chooseFiles()
            } label: {
                Label("Choose files", systemImage: "plus")
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Text(viewModel.commandPreview)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            if let message = viewModel.globalMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button("Clear completed") {
                viewModel.clearCompleted()
            }
            .disabled(viewModel.jobs.isEmpty)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        var didAccept = false

        for provider in providers where provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                let url: URL?

                if let data = item as? Data {
                    url = URL(dataRepresentation: data, relativeTo: nil)
                } else if let droppedURL = item as? URL {
                    url = droppedURL
                } else {
                    url = nil
                }

                if let url {
                    Task { @MainActor in
                        viewModel.addFiles([url])
                    }
                }
            }

            didAccept = true
        }

        return didAccept
    }
}

private struct SectionTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title.uppercased())
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
    }
}

private struct PresetRow: View {
    let preset: AudioQualityPreset
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                    .frame(width: 18)

                VStack(alignment: .leading, spacing: 2) {
                    Text(preset.title)
                        .font(.callout.weight(.medium))
                    Text(preset.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(10)
        .background(isSelected ? Color.accentColor.opacity(0.12) : Color.clear, in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct JobRow: View {
    let job: ConversionJob
    let revealAction: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 5) {
                Text(job.inputURL.lastPathComponent)
                    .font(.callout.weight(.medium))
                    .lineLimit(1)

                if let mediaInfo = job.mediaInfo, mediaInfo.isLossyMP3 {
                    Text(TruthCopy.alreadyMP3Warning)
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .lineLimit(2)
                } else {
                    Text(detailText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            statusView
        }
        .padding(.vertical, 10)
    }

    private var detailText: String {
        guard let duration = job.mediaInfo?.durationSeconds else {
            return job.outputURL.lastPathComponent
        }

        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)m \(seconds)s to \(job.outputURL.lastPathComponent)"
    }

    private var statusView: some View {
        Group {
            switch job.state {
            case .ready:
                Text("Ready")
                    .foregroundStyle(.secondary)
            case .running:
                ProgressView()
                    .controlSize(.small)
            case .completed:
                Button {
                    revealAction()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
                .buttonStyle(.plain)
            case .failed:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
            case .cancelled:
                Text("Cancelled")
                    .foregroundStyle(.secondary)
            }
        }
        .font(.caption.weight(.medium))
    }

    private var iconName: String {
        switch job.state {
        case .completed:
            "waveform.circle.fill"
        case .failed:
            "exclamationmark.circle.fill"
        default:
            "waveform"
        }
    }

    private var iconColor: Color {
        switch job.state {
        case .completed:
            .green
        case .failed:
            .red
        default:
            .secondary
        }
    }
}
