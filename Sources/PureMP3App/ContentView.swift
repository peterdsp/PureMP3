import PureMP3Core
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Bindable var viewModel: AppViewModel
    @State private var isDropTargeted = false

    var body: some View {
        ZStack {
            LiquidGlassBackground(mode: viewModel.displayMode)

            VStack(spacing: 0) {
                header

                HStack(spacing: 16) {
                    sidebar
                    mainContent
                }
                .padding(.horizontal, 20)

                commandBar
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .liquidGlass(RoundedRectangle(cornerRadius: 28, style: .continuous), tint: Color.accentColor, mode: viewModel.displayMode, strokeOpacity: 0.34)
        }
        .background(WindowConfigurator())
        .preferredColorScheme(.dark)
        .frame(width: 1120, height: 760)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            handleDrop(providers)
        }
        .overlay {
            if isDropTargeted {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.accentColor.opacity(0.82), lineWidth: 2)
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
                    .lineLimit(1)

                Text("A small, honest MP3 converter powered by FFmpeg.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .layoutPriority(1)

            Spacer()

            HStack(spacing: 12) {
                Picker("Display mode", selection: $viewModel.displayMode) {
                    ForEach(AppViewModel.DisplayMode.allCases) { mode in
                        Text(mode.title)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 168, height: 38)
                .fixedSize()
                .liquidGlass(Capsule(), tint: Color.accentColor, mode: viewModel.displayMode, strokeOpacity: 0.18, shadowOpacity: 0.08, interactive: true)

                Button {
                    viewModel.chooseFiles()
                } label: {
                    Label("Add files", systemImage: "plus")
                }
                .buttonStyle(LiquidGlassButtonStyle(mode: viewModel.displayMode))

                Button {
                    viewModel.convertAll()
                } label: {
                    Label("Convert", systemImage: "waveform")
                }
                .buttonStyle(LiquidGlassButtonStyle(prominent: true, mode: viewModel.displayMode))
                .disabled(!viewModel.hasJobs || viewModel.isConverting)
                .keyboardShortcut(.return, modifiers: .command)
            }
            .fixedSize()
        }
        .padding(.trailing, 30)
        .padding(.leading, 132)
        .padding(.top, 42)
        .padding(.bottom, 22)
        .frame(height: 124)
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle("Quality")

                ForEach(AudioQualityPreset.allCases) { preset in
                    PresetRow(
                        preset: preset,
                        isSelected: viewModel.selectedPreset == preset,
                        mode: viewModel.displayMode
                    ) {
                        viewModel.selectedPreset = preset
                    }
                }
            }

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
                    .liquidGlass(RoundedRectangle(cornerRadius: 12, style: .continuous), tint: Color.accentColor, mode: viewModel.displayMode, strokeOpacity: 0.22, shadowOpacity: 0.10, interactive: true)
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
        .padding(.vertical, 18)
        .frame(width: 320)
        .liquidGlass(RoundedRectangle(cornerRadius: 22, style: .continuous), tint: Color(red: 0.38, green: 0.70, blue: 1.0), mode: viewModel.displayMode, strokeOpacity: 0.26, shadowOpacity: 0.14)
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            if viewModel.jobs.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(viewModel.jobs) { job in
                        JobRow(job: job, mode: viewModel.displayMode) {
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
        .liquidGlass(RoundedRectangle(cornerRadius: 22, style: .continuous), tint: Color(red: 0.00, green: 0.76, blue: 0.64), mode: viewModel.displayMode, strokeOpacity: 0.24, shadowOpacity: 0.16)
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
                .buttonStyle(LiquidGlassButtonStyle(prominent: true, mode: viewModel.displayMode))
            }
            .frame(width: 500, height: 280)
            .liquidGlass(RoundedRectangle(cornerRadius: 24, style: .continuous), tint: Color.accentColor, mode: viewModel.displayMode, strokeOpacity: 0.36, shadowOpacity: 0.24, interactive: true)
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.14), style: StrokeStyle(lineWidth: 1, dash: [6, 6]))
            }

            HStack(spacing: 10) {
                InfoPill(icon: "waveform", title: "VBR first", value: "smaller, still excellent", mode: viewModel.displayMode)
                InfoPill(icon: "checkmark.seal", title: "No myths", value: "honest bitrate rules", mode: viewModel.displayMode)
                InfoPill(icon: "terminal", title: "Visible", value: "shows the command", mode: viewModel.displayMode)
            }
            .frame(width: 720)

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
        .padding(.horizontal, 20)
        .frame(height: 46)
        .liquidGlass(Capsule(), tint: Color.accentColor, mode: viewModel.displayMode, strokeOpacity: 0.20, shadowOpacity: 0.12)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
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
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.secondary)
    }
}

private struct PresetRow: View {
    let preset: AudioQualityPreset
    let isSelected: Bool
    let mode: AppViewModel.DisplayMode
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
        .liquidGlass(
            RoundedRectangle(cornerRadius: 12, style: .continuous),
            tint: isSelected ? Color.accentColor : Color.white,
            mode: mode,
            strokeOpacity: isSelected ? 0.34 : 0.12,
            shadowOpacity: isSelected ? 0.12 : 0.04,
            interactive: true
        )
        .opacity(isSelected ? 1.0 : 0.78)
    }
}

private struct InfoPill: View {
    let icon: String
    let title: String
    let value: String
    let mode: AppViewModel.DisplayMode

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
        .liquidGlass(RoundedRectangle(cornerRadius: 14, style: .continuous), tint: Color.accentColor, mode: mode, strokeOpacity: 0.18, shadowOpacity: 0.08)
    }
}

private struct JobRow: View {
    let job: ConversionJob
    let mode: AppViewModel.DisplayMode
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
        .padding(.horizontal, 12)
        .liquidGlass(RoundedRectangle(cornerRadius: 16, style: .continuous), tint: Color.white, mode: mode, strokeOpacity: 0.18, shadowOpacity: 0.08, interactive: true)
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
