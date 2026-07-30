import SwiftUI

struct CuisineFolderPagesView: View {
    let folder: CuisineFolder
    @State private var selectedRecipe: RecipeDocument?

    private let titleHeight: CGFloat = 44
    private let stackStep: CGFloat = 44
    private let closedTabHeight: CGFloat = 48
    private let frontPageLip: CGFloat = 8

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ExilyAppHeader(
                    title: folder.name,
                    subtitle: "\(folder.recipes.count) closed pages · tap to open"
                )

                VStack(alignment: .leading, spacing: 12) {
                    ExilySectionHeader(title: "Pages")
                        .padding(.horizontal, 20)

                    ExilySettingsCard {
                        pageStack
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ExilyColors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedRecipe) { recipe in
            RecipeArtifactView(document: recipe)
                .presentationDragIndicator(.visible)
        }
        .onChange(of: selectedRecipe) { _, recipe in
            if recipe != nil { ExilyHaptics.tap(.success) }
        }
    }

    private var pageStack: some View {
        let recipes = folder.recipes
        let stackHeight = stackStep * CGFloat(max(recipes.count - 1, 0))
            + (recipes.isEmpty ? 0 : titleHeight + frontPageLip)

        return ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(ExilyColors.surfaceMuted)
                .frame(height: stackHeight + 20)
                .padding(.horizontal, 6)
                .offset(y: 12)

            VStack(spacing: -(closedTabHeight - stackStep)) {
                ForEach(Array(recipes.enumerated()), id: \.element.id) { index, recipe in
                    ClosedRecipePage(
                        title: recipe.title,
                        isFront: index == recipes.count - 1,
                        titleHeight: titleHeight,
                        tabHeight: closedTabHeight,
                        lipHeight: index == recipes.count - 1 ? frontPageLip : 0
                    ) {
                        selectedRecipe = recipe
                    }
                    .zIndex(Double(index))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: stackHeight + titleHeight + frontPageLip)
        .padding(.vertical, 8)
    }
}

private struct ClosedRecipePage: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let isFront: Bool
    let titleHeight: CGFloat
    let tabHeight: CGFloat
    let lipHeight: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                titleBar
                if lipHeight > 0 {
                    ExilyColors.background
                        .frame(height: lipHeight)
                }
            }
            .background(ExilyKeyboardChrome.chip)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(ExilyKeyboardChrome.chipStroke(for: colorScheme), lineWidth: 1)
            )
            .shadow(
                color: Color.black.opacity(isFront ? 0.14 : 0.08),
                radius: isFront ? 7 : 4,
                x: 0,
                y: isFront ? 3 : 2
            )
        }
        .buttonStyle(ExilyPressableCardStyle(hapticStrength: .action))
        .frame(height: tabHeight + lipHeight)
    }

    private var titleBar: some View {
        HStack(spacing: 10) {
            Text(title.lowercased())
                .font(.appFont(size: 14, weight: .bold))
                .foregroundColor(ExilyColors.textPrimary)
                .lineLimit(1)

            Spacer(minLength: 0)

            Image(systemName: "doc.text")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(ExilyColors.textSecondary)
        }
        .padding(.horizontal, 14)
        .frame(height: titleHeight)
    }
}

#Preview {
    NavigationStack {
        CuisineFolderPagesView(folder: MockRecipeData.folders[0])
    }
}
