import SwiftUI

enum ExilyColors {
    static let background = Color.white
    static let surface = Color(red: 0.96, green: 0.96, blue: 0.97)
    static let surfaceMuted = Color(red: 0.94, green: 0.94, blue: 0.95)
    static let accentBlue = Color(red: 0.23, green: 0.51, blue: 0.96)
    static let textPrimary = Color.black
    static let textSecondary = Color(red: 0.45, green: 0.45, blue: 0.48)
    static let textTertiary = Color(red: 0.55, green: 0.55, blue: 0.58)
    static let border = Color(red: 0.90, green: 0.90, blue: 0.92)
}

extension View {
    func exilySoftShadow(radius: CGFloat = 8, y: CGFloat = 4) -> some View {
        shadow(color: Color.black.opacity(0.08), radius: radius, x: 0, y: y)
    }

    func exilySurfaceCard(cornerRadius: CGFloat = 20) -> some View {
        background(ExilyColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

struct TactileButtonStyle: ButtonStyle {
    var isActive: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appFont(size: 15, weight: .bold))
            .foregroundColor(isActive ? .white : .black)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isActive ? ExilyColors.accentBlue : ExilyColors.surfaceMuted)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        isActive ? ExilyColors.accentBlue.opacity(0.3) : ExilyColors.border,
                        lineWidth: 1
                    )
            )
            .shadow(
                color: Color.black.opacity(isActive ? 0.18 : 0.06),
                radius: configuration.isPressed ? 2 : 6,
                x: 0,
                y: configuration.isPressed ? 1 : 3
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct Raised3DButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    var cornerRadius: CGFloat = 10
    var isDark: Bool = false
    var expands: Bool = false

    private var fill: Color {
        if isDark {
            return colorScheme == .dark
                ? Color(uiColor: .systemGray3)
                : Color(red: 0.15, green: 0.15, blue: 0.16)
        }
        return Color(uiColor: .systemGray6)
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: expands ? .infinity : nil)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        Color.white.opacity(isDark ? 0.22 : 0.75),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: Color.black.opacity(configuration.isPressed ? 0.08 : 0.14),
                radius: configuration.isPressed ? 2 : 5,
                x: 0,
                y: configuration.isPressed ? 1 : 2
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
