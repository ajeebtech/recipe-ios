import SwiftUI

struct ArtifactSegmentedControl<T: Hashable & CaseIterable & Identifiable>: View where T.AllCases: RandomAccessCollection, T: RawRepresentable, T.RawValue == String {
    @Binding var selection: T
    let options: T.AllCases

    init(selection: Binding<T>, options: T.AllCases = T.allCases) {
        _selection = selection
        self.options = options
    }

    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(options), id: \.id) { option in
                Button {
                    withAnimation(.easeOut(duration: 0.16)) {
                        selection = option
                    }
                } label: {
                    Text(option.rawValue)
                        .font(.system(size: 12.5, weight: selection == option ? .semibold : .medium))
                        .foregroundColor(selection == option ? ArtifactColors.ink : ArtifactColors.ink2)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(selection == option ? ArtifactColors.card : Color.clear)
                                .shadow(
                                    color: selection == option ? Color.black.opacity(0.09) : .clear,
                                    radius: 2,
                                    x: 0,
                                    y: 1
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(2)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(ArtifactColors.segBackground)
        )
    }
}

struct ArtifactButton: View {
    enum Style {
        case primary, secondary, ghost
    }

    let title: String
    var style: Style = .secondary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12.5, weight: style == .primary ? .semibold : .medium))
                .foregroundColor(foreground)
                .padding(.horizontal, 13)
                .padding(.vertical, 6.5)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(background)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(border, lineWidth: style == .ghost ? 0 : 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }

    private var foreground: Color {
        switch style {
        case .primary: return .white
        case .secondary: return ArtifactColors.ink
        case .ghost: return ArtifactColors.ink2
        }
    }

    private var background: Color {
        switch style {
        case .primary: return ArtifactColors.accent
        case .secondary: return ArtifactColors.card
        case .ghost: return .clear
        }
    }

    private var border: Color {
        style == .primary ? ArtifactColors.accent : ArtifactColors.rule2
    }
}

struct ArtifactEyebrow: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10.5, weight: .semibold))
            .kerning(1.6)
            .foregroundColor(ArtifactColors.ink3)
    }
}

struct ArtifactMetaLine: View {
    let parts: [(String, String)]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(parts.enumerated()), id: \.offset) { index, part in
                if index > 0 {
                    Text("·")
                        .foregroundColor(ArtifactColors.ink4)
                        .padding(.horizontal, 8)
                }
                Text(part.0)
                    .font(.system(size: 13))
                    .foregroundColor(ArtifactColors.ink2)
                + Text(" \(part.1)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(ArtifactColors.ink)
            }
        }
        .monospacedDigit()
    }
}
