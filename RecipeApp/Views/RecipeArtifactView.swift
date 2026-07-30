import SwiftUI

struct RecipeArtifactView: View {
    let document: RecipeDocument
    @Environment(\.dismiss) private var dismiss

    @State private var viewMode: RecipeViewMode = .diagram
    @State private var unitDisplay: UnitDisplay = .both

    private var parsed: ParsedRecipe { document.parsed }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    masthead
                    controls
                    if let error = parsed.error {
                        errorBanner(error)
                    }
                    artifactCard
                    footerNote
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(ExilyColors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(ExilyColors.textPrimary)
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(Raised3DButtonStyle(cornerRadius: 12, isDark: false, hapticStrength: .action))
                }
            }
        }
    }

    private var masthead: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    ExilyChip(text: "recipe artifact")
                    Text((parsed.meta.title.isEmpty ? document.title : parsed.meta.title).lowercased())
                        .font(.appFont(size: 24, weight: .bold))
                        .foregroundColor(ExilyColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 12)
            }

            if !metaParts.isEmpty {
                HStack(spacing: 8) {
                    ForEach(Array(metaParts.enumerated()), id: \.offset) { _, part in
                        ExilyChip(text: "\(part.0.lowercased()) · \(part.1.lowercased())")
                    }
                }
            }

            ExilySegmentedControl(
                selection: $viewMode,
                options: RecipeViewMode.allCases,
                label: { $0.rawValue }
            )
        }
    }

    private var metaParts: [(String, String)] {
        var parts: [(String, String)] = []
        if !parsed.meta.yield.isEmpty { parts.append(("Yield", parsed.meta.yield)) }
        if !parsed.meta.pan.isEmpty { parts.append(("Pan", parsed.meta.pan)) }
        if !parsed.meta.oven.isEmpty { parts.append(("Oven", parsed.meta.oven)) }
        return parts
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("units")
                .font(.appFont(size: 14, weight: .semibold))
                .foregroundColor(ExilyColors.textPrimary)

            ExilySegmentedControl(
                selection: $unitDisplay,
                options: UnitDisplay.allCases,
                label: { $0.rawValue }
            )

            Button {} label: {
                Text("cook this")
            }
            .buttonStyle(TactileButtonStyle(isActive: true))
        }
    }

    private var artifactCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                switch viewMode {
                case .diagram:
                    RecipeDiagramView(recipe: parsed, units: unitDisplay)
                case .recipe:
                    RecipeProseView(recipe: parsed)
                }
            }
            .padding(20)
        }
        .background(ArtifactColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(ExilyColors.border, lineWidth: 1)
        )
        .exilySoftShadow(radius: 8, y: 4)
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("!")
                .font(.appFont(size: 13, weight: .bold))
            Text(message)
                .font(.appFont(size: 13, weight: .medium))
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundColor(ExilyColors.textPrimary)
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ExilyColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(ExilyColors.border, lineWidth: 1)
        )
    }

    private var footerNote: some View {
        Text("tap cells to trace the flow")
            .font(.appFont(size: 11, weight: .medium))
            .foregroundColor(ExilyColors.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)
    }
}

#Preview {
    RecipeArtifactView(document: MockRecipeData.folders[0].recipes[0])
}
