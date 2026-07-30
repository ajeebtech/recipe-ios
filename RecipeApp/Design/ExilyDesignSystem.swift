import SwiftUI

enum ExilyColors {
    static let background = Color.white
    static let surface = Color(red: 0.96, green: 0.96, blue: 0.97)
    static let surfaceMuted = Color(red: 0.94, green: 0.94, blue: 0.95)
    static let brandLime = Color(red: 0.82, green: 0.93, blue: 0.35)
    static let accentBlue = Color(red: 0.23, green: 0.51, blue: 0.96)
    static let textPrimary = Color.black
    static let textSecondary = Color(red: 0.45, green: 0.45, blue: 0.48)
    static let textTertiary = Color(red: 0.55, green: 0.55, blue: 0.58)
    static let border = Color(red: 0.90, green: 0.90, blue: 0.92)
    static let tabInactive = Color(red: 0.55, green: 0.55, blue: 0.58)
}

/// Keyboard strip chrome — matches ExilyKeyboard `KeyboardTheme`.
enum ExilyKeyboardChrome {
    static var panel: Color { Color(uiColor: .systemGray6) }
    static var chip: Color { Color(uiColor: .systemGray5) }

    static func chipStroke(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.14) : Color.white.opacity(0.75)
    }
}

struct ExilySoftShadow: ViewModifier {
    var radius: CGFloat = 8
    var y: CGFloat = 4

    func body(content: Content) -> some View {
        content.shadow(color: Color.black.opacity(0.08), radius: radius, x: 0, y: y)
    }
}

extension View {
    func exilySoftShadow(radius: CGFloat = 8, y: CGFloat = 4) -> some View {
        modifier(ExilySoftShadow(radius: radius, y: y))
    }

    func exilySurfaceCard(cornerRadius: CGFloat = 20) -> some View {
        background(ExilyColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

struct ExilyBrandPill: View {
    var title: String = "recipes"

    var body: some View {
        Text(title)
            .font(.appFont(size: 13, weight: .bold))
            .foregroundColor(.white)
            .textCase(.lowercase)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.black))
    }
}

struct ExilyAvatarView: View {
    let label: String
    var size: CGFloat = 44

    private var initials: String {
        let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "R" }
        let parts = trimmed.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(trimmed.prefix(1)).uppercased()
    }

    var body: some View {
        ZStack {
            Circle().fill(ExilyColors.surfaceMuted)
            Text(initials)
                .font(.appFont(size: size * 0.34, weight: .bold))
                .foregroundColor(ExilyColors.textPrimary)
        }
        .frame(width: size, height: size)
        .overlay(Circle().stroke(ExilyColors.border, lineWidth: 1))
    }
}

struct ExilyAppHeader: View {
    let title: String
    let subtitle: String
    var lowercaseStyle: Bool = true

    private func styled(_ text: String) -> String {
        lowercaseStyle ? text.lowercased() : text
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ExilyAvatarView(label: title)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(styled(title))
                        .font(.appFont(size: 15, weight: .bold))
                        .foregroundColor(ExilyColors.textPrimary)
                        .lineLimit(1)
                    ExilyBrandPill()
                }

                Text(styled(subtitle))
                    .font(.appFont(size: 11, weight: .medium))
                    .foregroundColor(ExilyColors.textSecondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 4)
    }
}

struct ExilySectionHeader: View {
    let title: String

    var body: some View {
        Text(title.lowercased())
            .font(.appFont(size: 17, weight: .bold))
            .foregroundColor(ExilyColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)
    }
}

struct ExilySettingsCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(20)
            .background(ExilyColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(ExilyColors.border, lineWidth: 1)
            )
    }
}

struct ExilyChip: View {
    @Environment(\.colorScheme) private var colorScheme
    let text: String

    var body: some View {
        Text(text.lowercased())
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(ExilyColors.textPrimary)
            .padding(.vertical, 7)
            .padding(.horizontal, 11)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(ExilyKeyboardChrome.chip)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(ExilyKeyboardChrome.chipStroke(for: colorScheme), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 5, x: 0, y: 2)
            .shadow(color: Color.black.opacity(0.06), radius: 1.5, x: 0, y: 0)
    }
}

struct ExilySegmentedControl<T: Hashable>: View {
    @Binding var selection: T
    let options: [T]
    let label: (T) -> String
    var compact: Bool = false

    init(
        selection: Binding<T>,
        options: [T],
        compact: Bool = false,
        label: @escaping (T) -> String
    ) {
        _selection = selection
        self.options = options
        self.compact = compact
        self.label = label
    }

    var body: some View {
        HStack(spacing: compact ? 6 : 8) {
            ForEach(options, id: \.self) { option in
                Button {
                    ExilyHaptics.tap(.select)
                    withAnimation(.easeOut(duration: 0.1)) {
                        selection = option
                    }
                } label: {
                    Text(label(option).lowercased())
                        .font(.appFont(size: compact ? 11 : 13, weight: .bold))
                        .foregroundColor(selection == option ? .white : ExilyColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: compact ? 30 : 38)
                        .background(
                            RoundedRectangle(cornerRadius: compact ? 9 : 12, style: .continuous)
                                .fill(selection == option ? ExilyColors.accentBlue : ExilyColors.surfaceMuted)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: compact ? 9 : 12, style: .continuous)
                                .stroke(
                                    selection == option
                                        ? ExilyColors.accentBlue.opacity(0.3)
                                        : ExilyColors.border,
                                    lineWidth: 1
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct TactileButtonStyle: ButtonStyle {
    var isActive: Bool
    var compact: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appFont(size: compact ? 13 : 15, weight: .bold))
            .foregroundColor(isActive ? .white : .black)
            .padding(.vertical, compact ? 9 : 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: compact ? 10 : 14, style: .continuous)
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
            .exilyHapticOnPress(configuration.isPressed, strength: .action)
    }
}

struct Raised3DButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    var cornerRadius: CGFloat = 12
    var isDark: Bool = false
    var expands: Bool = false
    var hapticStrength: ExilyHaptics.Strength = .light

    private var fill: Color {
        if isDark {
            return colorScheme == .dark
                ? Color(uiColor: .systemGray3)
                : Color(red: 0.15, green: 0.15, blue: 0.16)
        }
        return ExilyKeyboardChrome.panel
    }

    private var highlightOpacity: Double {
        if isDark { return colorScheme == .dark ? 0.35 : 0.22 }
        return colorScheme == .dark ? 0.18 : 0.85
    }

    private var shadowOpacity: Double {
        colorScheme == .dark ? 0.35 : 0.16
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
                        LinearGradient(
                            colors: [
                                Color.white.opacity(highlightOpacity),
                                Color.black.opacity(isDark ? 0.28 : 0.08)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: Color.black.opacity(configuration.isPressed ? shadowOpacity * 0.5 : shadowOpacity),
                radius: configuration.isPressed ? 2 : 5,
                x: 0,
                y: configuration.isPressed ? 1 : 2
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
            .exilyHapticOnPress(configuration.isPressed, strength: hapticStrength)
    }
}

struct ExilyPressableCardStyle: ButtonStyle {
    var hapticStrength: ExilyHaptics.Strength = .light

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
            .exilyHapticOnPress(configuration.isPressed, strength: hapticStrength)
    }
}
