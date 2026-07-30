import SwiftUI

struct RecipeArtifactView: View {
    let document: RecipeDocument
    @Environment(\.dismiss) private var dismiss

    @State private var viewMode: RecipeViewMode = .diagram
    @State private var unitDisplay: UnitDisplay = .both
    private let parsed: ParsedRecipe

    init(document: RecipeDocument) {
        self.document = document
        parsed = document.parsed
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let width = max(proxy.size.width, 1)
                let height = max(proxy.size.height, 1)
                let size = CGSize(width: width, height: height)

                HStack(alignment: .top, spacing: 24) {
                    sidebar
                        .frame(width: min(240, width * 0.28), alignment: .topLeading)
                        .frame(maxHeight: .infinity, alignment: .top)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if let error = parsed.error {
                                errorBanner(error)
                            }
                            artifactCard(width: diagramWidth(in: size))
                            footerNote
                        }
                        .padding(.bottom, 24)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .frame(width: width, height: height, alignment: .topLeading)
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
                            .frame(width: 36, height: 36)
                            .background(ExilyColors.surfaceMuted, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(ExilyColors.border, lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .landscapeReveal()
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 10) {
            masthead
            controls
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private func diagramWidth(in size: CGSize) -> CGFloat {
        let width = max(size.width, 1)
        let sidebarWidth = min(240, width * 0.28)
        return max(width - sidebarWidth - 56, 1)
    }

    private var masthead: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text((parsed.meta.title.isEmpty ? document.title : parsed.meta.title).lowercased())
                .font(.appFont(size: 20, weight: .bold))
                .foregroundColor(ExilyColors.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            if !metaLine.isEmpty {
                Text(metaLine)
                    .font(.appFont(size: 11, weight: .medium))
                    .foregroundColor(ExilyColors.textSecondary)
                    .lineLimit(2)
            }

            ExilySegmentedControl(
                selection: $viewMode,
                options: RecipeViewMode.allCases,
                compact: true,
                label: { $0.rawValue }
            )
        }
    }

    private var metaLine: String {
        metaParts.map { "\($0.0.lowercased()) · \($0.1.lowercased())" }.joined(separator: " · ")
    }

    private var metaParts: [(String, String)] {
        var parts: [(String, String)] = []
        if !parsed.meta.yield.isEmpty { parts.append(("Yield", parsed.meta.yield)) }
        if !parsed.meta.pan.isEmpty { parts.append(("Pan", parsed.meta.pan)) }
        if !parsed.meta.oven.isEmpty { parts.append(("Oven", parsed.meta.oven)) }
        return parts
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 8) {
            ExilySegmentedControl(
                selection: $unitDisplay,
                options: UnitDisplay.allCases,
                compact: true,
                label: { $0.rawValue }
            )

            Button {} label: {
                Text("cook this")
            }
            .buttonStyle(TactileButtonStyle(isActive: true, compact: true))
        }
    }

    private func artifactCard(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                switch viewMode {
                case .diagram:
                    RecipeDiagramView(
                        recipe: parsed,
                        units: unitDisplay,
                        availableWidth: max(width - 40, 1)
                    )
                case .recipe:
                    RecipeProseView(recipe: parsed)
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
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
