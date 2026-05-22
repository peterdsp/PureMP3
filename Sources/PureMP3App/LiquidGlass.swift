import SwiftUI

struct LiquidGlassBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.07, blue: 0.10),
                    Color(red: 0.03, green: 0.09, blue: 0.10),
                    Color(red: 0.08, green: 0.06, blue: 0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

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

            LinearGradient(
                colors: [
                    .white.opacity(0.08),
                    .clear,
                    .black.opacity(0.18)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}

struct LiquidGlassSurface<S: Shape>: ViewModifier {
    let shape: S
    let tint: Color
    let strokeOpacity: Double
    let shadowOpacity: Double
    let interactive: Bool

    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    shape
                        .fill(.ultraThinMaterial)

                    shape
                        .fill(
                            LinearGradient(
                                colors: [
                                    tint.opacity(0.22),
                                    Color.white.opacity(0.05),
                                    Color.black.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    shape
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(strokeOpacity),
                                    .white.opacity(0.08),
                                    tint.opacity(strokeOpacity * 0.55)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            }
            .shadow(color: .black.opacity(shadowOpacity), radius: interactive ? 18 : 24, y: interactive ? 10 : 16)
    }
}

extension View {
    func liquidGlass<S: Shape>(
        _ shape: S,
        tint: Color = .white,
        strokeOpacity: Double = 0.30,
        shadowOpacity: Double = 0.24,
        interactive: Bool = false
    ) -> some View {
        modifier(
            LiquidGlassSurface(
                shape: shape,
                tint: tint,
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

    init(prominent: Bool = false) {
        self.prominent = prominent
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.semibold))
            .foregroundStyle(prominent ? Color.white : Color.primary)
            .padding(.horizontal, 15)
            .frame(height: 38)
            .background {
                Capsule()
                    .fill(prominent ? Color.accentColor.opacity(isEnabled ? 0.72 : 0.16) : Color.white.opacity(isEnabled ? 0.10 : 0.04))
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay {
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(isEnabled ? 0.46 : 0.14),
                                        .white.opacity(0.10)
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
}
