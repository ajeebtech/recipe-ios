import SwiftUI

struct CuisineLibraryView: View {
    @State private var openFolderID: String?
    @State private var selectedRecipe: RecipeDocument?
    @State private var dragOffset: CGFloat = 0

    private let folders = MockRecipeData.folders

    var body: some View {
        ZStack {
            ExilyColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    folderGrid
                    if let openFolderID, let folder = folders.first(where: { $0.id == openFolderID }) {
                        openFolderPanel(folder)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 120)
            }
        }
        .sheet(item: $selectedRecipe) { recipe in
            RecipeArtifactView(document: recipe)
                .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("recipes")
                .font(.appFont(size: 28, weight: .bold))
                .foregroundColor(ExilyColors.textPrimary)
            Text("open a cuisine folder, then pull up a recipe artifact")
                .font(.appFont(size: 13, weight: .medium))
                .foregroundColor(ExilyColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var folderGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
            spacing: 14
        ) {
            ForEach(folders) { folder in
                CuisineFolderCard(
                    folder: folder,
                    isOpen: openFolderID == folder.id
                ) {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                        openFolderID = openFolderID == folder.id ? nil : folder.id
                    }
                }
            }
        }
    }

    private func openFolderPanel(_ folder: CuisineFolder) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: folder.symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(folder.tint.color)
                Text(folder.name)
                    .font(.appFont(size: 17, weight: .bold))
                    .foregroundColor(ExilyColors.textPrimary)
                Spacer()
                Text("\(folder.recipes.count) recipes")
                    .font(.appFont(size: 12, weight: .medium))
                    .foregroundColor(ExilyColors.textSecondary)
            }

            VStack(spacing: 10) {
                ForEach(folder.recipes) { recipe in
                    Button {
                        selectedRecipe = recipe
                    } label: {
                        RecipePullCard(recipe: recipe, tint: folder.tint.color)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(ExilyColors.background)
                .shadow(color: folder.tint.color.opacity(0.12), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(folder.tint.color.opacity(0.18), lineWidth: 1)
        )
    }
}

struct CuisineFolderCard: View {
    let folder: CuisineFolder
    let isOpen: Bool
    let action: () -> Void

    @State private var tabLift: CGFloat = 0

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                folderTab
                folderBody
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isOpen ? 1.02 : 1)
        .animation(.spring(response: 0.35, dampingFraction: 0.78), value: isOpen)
    }

    private var folderTab: some View {
        HStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(folder.tint.soft)
                .frame(width: 54, height: 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(folder.tint.color.opacity(0.25), lineWidth: 1)
                )
                .offset(y: isOpen ? -4 : 0)
            Spacer()
        }
        .padding(.horizontal, 10)
    }

    private var folderBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(folder.tint.soft)
                        .frame(width: 42, height: 42)
                    Image(systemName: folder.symbol)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(folder.tint.color)
                }
                Spacer()
                Image(systemName: isOpen ? "folder.fill.badge.minus" : "folder.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isOpen ? folder.tint.color : ExilyColors.textTertiary)
            }

            Text(folder.name)
                .font(.appFont(size: 16, weight: .bold))
                .foregroundColor(ExilyColors.textPrimary)

            Text("\(folder.recipes.count) artifacts")
                .font(.appFont(size: 12, weight: .medium))
                .foregroundColor(ExilyColors.textSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [ExilyColors.background, folder.tint.soft.opacity(isOpen ? 0.55 : 0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isOpen ? folder.tint.color.opacity(0.35) : ExilyColors.border, lineWidth: 1)
        )
        .exilySoftShadow(radius: isOpen ? 12 : 8, y: isOpen ? 6 : 4)
    }
}

struct RecipePullCard: View {
    let recipe: RecipeDocument
    let tint: Color

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(ArtifactColors.accentSoft)
                .frame(width: 46, height: 58)
                .overlay(
                    VStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(ArtifactColors.accentLine)
                                .frame(height: 2)
                                .padding(.horizontal, 8)
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(ArtifactColors.accentLine, lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title.lowercased())
                    .font(.appFont(size: 15, weight: .bold))
                    .foregroundColor(ExilyColors.textPrimary)
                Text(recipe.subtitle)
                    .font(.appFont(size: 12, weight: .medium))
                    .foregroundColor(ExilyColors.textSecondary)
            }

            Spacer()

            Image(systemName: "arrow.up.left.and.arrow.down.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(tint)
                .frame(width: 34, height: 34)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(ExilyColors.surfaceMuted)
                )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(ExilyColors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(ExilyColors.border, lineWidth: 1)
        )
    }
}

#Preview {
    CuisineLibraryView()
}
