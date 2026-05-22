import SwiftUI

struct LiquidGlassBackground: View {
    let mode: AppViewModel.DisplayMode

    var body: some View {
        ZStack {
            backgroundBase

            if mode == .liquidGlass {
                Circle()
                    .fill(Color(red: 0.00, green: 0.52, blue: 1.00).opacity(0.26))
                    .frame(width: 520, height: 520)
                    .blur(radius: 90)
                    .offset(x: 410, y: -260)

                Circle()
                    .fill(Color(red: 0.00, green: 0.78, blue: 0.58).opacity(0.18))
                    .frame(width: 560, height: 560)
                    .blur(radius: 110)
                    .offset(x: -420, y: 300)
            } else {
                Circle()
                    .fill(Color.accentColor.opacity(0.10))
                    .frame(width: 420, height: 420)
                    .blur(radius: 120)
                    .offset(x: 430, y: -300)
            }

            LinearGradient(
                colors: [
                    .white.opacity(mode == .oled ? 0.02 : 0.08),
                    .clear,
                    .black.opacity(mode == .oled ? 0.72 : 0.18)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }

    private var backgroundBase: some View {
        Group {
            switch mode {
            case .liquidGlass:
                LinearGradient(
                    colors: [
                        Color(red: 0.02, green: 0.05, blue: 0.09),
                        Color(red: 0.04, green: 0.08, blue: 0.11),
                        Color(red: 0.02, green: 0.03, blue: 0.06)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .oled:
                Color.black
            }
        }
    }
}

struct LiquidGlassSurface<S: Shape>: ViewModifier {
    let shape: S
    let tint: Color
    let mode: AppViewModel.DisplayMode
    let strokeOpacity: Double
    let shadowOpacity: Double
    let interactive: Bool

    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    if mode == .oled {
                        shape
                            .fill(Color.black.opacity(0.86))
                    } else {
                        shape
                            .fill(Color.white.opacity(0.055))
                    }

                    shape
                        .fill(
                            LinearGradient(
                                colors: [
                                    tint.opacity(mode == .oled ? 0.10 : 0.18),
                                    Color.white.opacity(mode == .oled ? 0.018 : 0.16),
                                    Color.black.opacity(mode == .oled ? 0.72 : 0.18)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    shape
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(mode == .oled ? strokeOpacity * 0.44 : max(strokeOpacity, 0.42)),
                                    .white.opacity(mode == .oled ? 0.035 : 0.16),
                                    tint.opacity(mode == .oled ? strokeOpacity * 0.72 : max(strokeOpacity * 0.70, 0.24))
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            }
            .shadow(
                color: .black.opacity(mode == .oled ? shadowOpacity * 1.5 : shadowOpacity * 0.65),
                radius: interactive ? 12 : 16,
                y: interactive ? 7 : 10
            )
    }
}

extension View {
    func liquidGlass<S: Shape>(
        _ shape: S,
        tint: Color = .white,
        mode: AppViewModel.DisplayMode = .liquidGlass,
        strokeOpacity: Double = 0.30,
        shadowOpacity: Double = 0.24,
        interactive: Bool = false
    ) -> some View {
        modifier(
            LiquidGlassSurface(
                shape: shape,
                tint: tint,
                mode: mode,
                strokeOpacity: strokeOpacity,
                shadowOpacity: shadowOpacity,
                interactive: interactive
            )
        )
    }
}

struct LiquidGlassButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    let prominent: Bool
    let mode: AppViewModel.DisplayMode

    init(prominent: Bool = false, mode: AppViewModel.DisplayMode = .liquidGlass) {
        self.prominent = prominent
        self.mode = mode
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.semibold))
            .foregroundStyle(prominent ? Color.white : Color.primary)
            .padding(.horizontal, 15)
            .frame(height: 38)
            .background {
                Capsule()
                    .fill(buttonFill)
                    .background {
                        if mode == .liquidGlass {
                            Capsule()
                                .fill(Color.white.opacity(0.10))
                        }
                    }
                    .overlay {
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(isEnabled ? (mode == .oled ? 0.20 : 0.46) : 0.14),
                                        Color.accentColor.opacity(mode == .oled ? 0.30 : 0.10)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(color: .black.opacity(configuration.isPressed ? 0.16 : 0.26), radius: configuration.isPressed ? 8 : 16, y: configuration.isPressed ? 5 : 10)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.48)
            .animation(.snappy(duration: 0.18), value: configuration.isPressed)
    }

    private var buttonFill: Color {
        if prominent {
            return Color.accentColor.opacity(isEnabled ? (mode == .oled ? 0.84 : 0.72) : 0.16)
        }

        return mode == .oled
            ? Color.white.opacity(isEnabled ? 0.055 : 0.025)
            : Color.white.opacity(isEnabled ? 0.10 : 0.04)
    }
}
