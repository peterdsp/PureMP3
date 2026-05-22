import SwiftUI

struct DisplayModeToggle: View {
    @Binding var selection: AppViewModel.DisplayMode

    var body: some View {
        HStack(spacing: 3) {
            ForEach(AppViewModel.DisplayMode.allCases) { mode in
                Button {
                    withAnimation(.snappy(duration: 0.22)) {
                        selection = mode
                    }
                } label: {
                    Text(mode.title)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(selection == mode ? Color.white : Color.white.opacity(0.72))
                        .frame(width: 70, height: 34)
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .background {
                    if selection == mode {
                        Capsule()
                            .fill(activeFill(for: mode))
                            .overlay {
                                Capsule()
                                    .strokeBorder(Color.white.opacity(0.28), lineWidth: 1)
                            }
                            .shadow(color: activeShadow(for: mode), radius: 10, y: 5)
                    }
                }
            }
        }
        .padding(4)
        .liquidGlass(
            Capsule(),
            tint: Color.accentColor,
            mode: selection,
            strokeOpacity: selection == .liquidGlass ? 0.36 : 0.22,
            shadowOpacity: 0.10,
            interactive: true
        )
        .fixedSize()
    }

    private func activeFill(for mode: AppViewModel.DisplayMode) -> Color {
        switch mode {
        case .liquidGlass:
            Color.white.opacity(0.18)
        case .oled:
            Color.accentColor.opacity(0.88)
        }
    }

    private func activeShadow(for mode: AppViewModel.DisplayMode) -> Color {
        switch mode {
        case .liquidGlass:
            Color.white.opacity(0.10)
        case .oled:
            Color.accentColor.opacity(0.30)
        }
    }
}
