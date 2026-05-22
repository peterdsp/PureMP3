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
                mainContent
            }
            Divider()
            commandBar
        }
        .frame(width: 940, height: 620)
        .background(AppColor.window)
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            handleDrop(providers)
        }
        .overlay {
            if isDropTargeted {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.accentColor, lineWidth: 2)
                    .padding(12)
                    .allowsHitTesting(false)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text("PureMP3")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.primary)

                Text("A small, honest MP3 converter powered by FFmpeg.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                viewModel.chooseFiles()
            } label: {
                Label("Add files", systemImage: "plus")
            }
            .controlSize(.large)

            Button {
                viewModel.convertAll()
            } label: {
                Label("Convert", systemImage: "waveform")
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.hasJobs || viewModel.isConverting)
            .keyboardShortcut(.return, modifiers: .command)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
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
                    HStack(spacing: 9) {
                        Image(systemName: "folder")
                            .frame(width: 18)
                        Text(viewModel.outputDirectory.lastPathComponent)
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .font(.callout.weight(.medium))
                    .padding(.horizontal, 12)
                    .frame(height: 42)
                    .background(AppColor.control, in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 8) {
                SectionTitle("Truth")

                Text(TruthCopy.bitrateTruth)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 2)

            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 20)
        .frame(width: 278)
        .background(AppColor.sidebar)
    }

    private var mainContent: some View {
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
                .scrollContentBackground(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.content)
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 34)

            VStack(spacing: 18) {
                Image(systemName: "arrow.down.doc")
                    .font(.system(size: 40, weight: .regular))
                    .foregroundStyle(.secondary)

                VStack(spacing: 6) {
                    Text("Drop files to convert")
                        .font(.system(size: 22, weight: .semibold))

                    Text("MP4, M4A, WAV, FLAC, and MP3 are supported.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Button {
                    viewModel.chooseFiles()
                } label: {
                    Label("Choose files", systemImage: "plus")
                }
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
            }
            .frame(width: 430, height: 260)
            .background(AppColor.dropZone, in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(AppColor.dropStroke, style: StrokeStyle(lineWidth: 1, dash: [6, 6]))
            }

            HStack(spacing: 10) {
                InfoPill(icon: "waveform", title: "VBR first", value: "smaller, still excellent")
                InfoPill(icon: "checkmark.seal", title: "No myths", value: "honest bitrate rules")
                InfoPill(icon: "terminal", title: "Visible", value: "shows the command")
            }
            .frame(width: 600)

            Spacer(minLength: 38)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var commandBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "terminal")
                .foregroundStyle(.secondary)

            Text(viewModel.commandPreview)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)

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
        .frame(height: 46)
        .background(AppColor.footer)
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

private enum AppColor {
    static let window = Color(nsColor: .windowBackgroundColor)
    static let sidebar = Color(nsColor: .underPageBackgroundColor)
    static let content = Color(nsColor: .windowBackgroundColor)
    static let footer = Color(nsColor: .controlBackgroundColor)
    static let control = Color(nsColor: .controlBackgroundColor)
    static let dropZone = Color(nsColor: .controlBackgroundColor).opacity(0.62)
    static let dropStroke = Color.secondary.opacity(0.28)
}

private struct SectionTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 11, weight: .semibold))
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
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                    .frame(width: 18)

                VStack(alignment: .leading, spacing: 2) {
                    Text(preset.title)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(preset.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.accentColor.opacity(0.10) : Color.clear)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(isSelected ? Color.accentColor.opacity(0.28) : Color.clear)
        }
    }
}

private struct InfoPill: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: icon)
                .font(.callout.weight(.medium))
                .foregroundStyle(Color.accentColor)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption.weight(.semibold))
                Text(value)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .frame(height: 48)
        .background(AppColor.control, in: RoundedRectangle(cornerRadius: 8))
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
