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
                VStack(alignment: .leading, spacing: 18) {
                    masthead
                    controls
                    if let error = parsed.error {
                        errorBanner(error)
                    }
                    cardContent
                    footerNote
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
            .background(ArtifactColors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(ExilyColors.textPrimary)
                            .frame(width: 34, height: 34)
                    }
                    .buttonStyle(Raised3DButtonStyle(cornerRadius: 10))
                }
            }
        }
    }

    private var masthead: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 8) {
                    ArtifactEyebrow(text: "Recipe diagram")
                    Text(parsed.meta.title.isEmpty ? document.title : parsed.meta.title)
                        .font(.system(size: 29, weight: .semibold))
                        .foregroundColor(ArtifactColors.ink)
                        .tracking(-0.4)
                        .fixedSize(horizontal: false, vertical: true)

                    if !metaParts.isEmpty {
                        ArtifactMetaLine(parts: metaParts)
                    }
                }
                Spacer(minLength: 12)
                ArtifactSegmentedControl(selection: $viewMode)
            }

            Rectangle()
                .fill(ArtifactColors.rule2)
                .frame(height: 1)
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
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("UNITS")
                    .font(.system(size: 10.5, weight: .semibold))
                    .kerning(1.3)
                    .foregroundColor(ArtifactColors.ink3)
                ArtifactSegmentedControl(selection: $unitDisplay)
            }
            Spacer()
            ArtifactButton(title: "Cook this", style: .primary) {}
        }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                switch viewMode {
                case .diagram:
                    RecipeDiagramView(recipe: parsed, units: unitDisplay)
                case .recipe:
                    RecipeProseView(recipe: parsed)
                }
            }
            .padding(22)
        }
        .background(ArtifactColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(ArtifactColors.rule, lineWidth: 1)
        )
        .shadow(color: Color(red: 0.063, green: 0.078, blue: 0.102).opacity(0.04), radius: 2, x: 0, y: 1)
        .shadow(color: Color(red: 0.063, green: 0.078, blue: 0.102).opacity(0.12), radius: 24, x: 0, y: 8)
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 11) {
            Text("!")
                .font(.artifactMono(size: 12, weight: .bold))
            Text(message)
                .font(.system(size: 12.5))
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundColor(Color(red: 0.541, green: 0.353, blue: 0.071))
        .padding(11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(red: 0.992, green: 0.961, blue: 0.902))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color(red: 0.902, green: 0.812, blue: 0.624), lineWidth: 1)
                )
        )
    }

    private var footerNote: some View {
        HStack(alignment: .top) {
            HStack(spacing: 16) {
                legendKey(label: "Operation", fill: ArtifactColors.band)
                legendKey(label: "Ingredient", fill: ArtifactColors.card)
            }
            Spacer()
            Text("Tap cells to trace the flow.")
                .font(.system(size: 11.5))
                .foregroundColor(ArtifactColors.ink3)
        }
        .padding(.top, 4)
    }

    private func legendKey(label: String, fill: Color) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(fill)
                .overlay(
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .stroke(ArtifactColors.rule2, lineWidth: 1)
                )
                .frame(width: 15, height: 11)
            Text(label)
                .font(.system(size: 11.5))
                .foregroundColor(ArtifactColors.ink3)
        }
    }
}

#Preview {
    RecipeArtifactView(document: MockRecipeData.folders[0].recipes[0])
}
