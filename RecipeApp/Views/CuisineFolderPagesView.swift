import SwiftUI

struct CuisineFolderPagesView: View {
    let folder: CuisineFolder
    @State private var selectedRecipe: RecipeDocument?
    @State private var selectedGenreID: String?

    private var recipes: [RecipeDocument] {
        MockRecipeData.bookRecipes(for: folder)
    }

    private var genres: [RecipeGenre] {
        recipes.reduce(into: []) { result, recipe in
            if !result.contains(recipe.genre) {
                result.append(recipe.genre)
            }
        }
    }

    private var selectedGenre: RecipeGenre? {
        genres.first { $0.id == selectedGenreID } ?? genres.first
    }

    private var visibleRecipes: [RecipeDocument] {
        guard let selectedGenre else { return [] }
        return recipes.filter { $0.genre == selectedGenre }
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 18) {
                    folderHero
                    bookStage(width: max(proxy.size.width - 32, 1))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                ZStack {
                    ExilyColors.background
                    LinearGradient(
                        colors: [folder.tint.color.opacity(0.08), ExilyColors.background],
                        startPoint: .top,
                        endPoint: .center
                    )
                }
                .ignoresSafeArea()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if selectedGenreID == nil {
                selectedGenreID = genres.first?.id
            }
        }
        .fullScreenCover(item: $selectedRecipe, onDismiss: {
            AppOrientationController.shared.lock(to: .portrait)
        }) { recipe in
            RecipeArtifactView(document: recipe)
        }
    }

    private var folderHero: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(folder.tint.soft)
                    .frame(width: 52, height: 52)
                Image(systemName: folder.symbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(folder.tint.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(folder.name.lowercased())
                    .font(.appFont(size: 26, weight: .bold))
                    .foregroundColor(ExilyColors.textPrimary)

                Text("\(genres.count) genres · \(recipes.count) recipes")
                    .font(.appFont(size: 12, weight: .medium))
                    .foregroundColor(ExilyColors.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.top, 6)
    }

    private func bookStage(width: CGFloat) -> some View {
        let pageWidth = max(width - 98, 220)
        let pageHeight: CGFloat = 570

        return ZStack(alignment: .topLeading) {
            bookPage(width: pageWidth, height: pageHeight)
                .offset(y: 43)

            genreTabs(width: pageWidth)

            VStack(spacing: 12) {
                ForEach(Array(visibleRecipes.enumerated()), id: \.element.id) { index, recipe in
                    RecipeBookmark(
                        recipe: recipe,
                        tint: folder.tint,
                        index: index
                    ) {
                        openRecipe(recipe)
                    }
                }
            }
            .offset(x: pageWidth - 18, y: 121)
            .animation(.spring(response: 0.35, dampingFraction: 0.82), value: selectedGenreID)
        }
        .frame(width: width, height: pageHeight + 52, alignment: .topLeading)
    }

    private func genreTabs(width: CGFloat) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(genres.enumerated()), id: \.element.id) { index, genre in
                    let isSelected = genre.id == selectedGenre?.id

                    Button {
                        ExilyHaptics.tap(.select)
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                            selectedGenreID = genre.id
                        }
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: genre.symbol)
                                .font(.system(size: 11, weight: .semibold))
                            Text(genre.name.lowercased())
                                .font(.appFont(size: 10, weight: .bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .foregroundColor(isSelected ? .white : ExilyColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 43)
                        .background(isSelected ? folder.tint.color : Color.white)
                        .overlay(alignment: .trailing) {
                            if index < genres.count - 1 {
                                Rectangle()
                                    .fill(ExilyColors.border)
                                    .frame(width: 1)
                            }
                        }
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(isSelected ? folder.tint.color : ExilyColors.border)
                                .frame(height: isSelected ? 3 : 1)
                        }
                    }
                    .buttonStyle(.plain)
            }
        }
        .frame(width: max(width, 1), height: 43)
        .background(Color.white)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 15,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 15
            )
        )
        .overlay {
            UnevenRoundedRectangle(
                topLeadingRadius: 15,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 15
            )
            .stroke(folder.tint.color.opacity(0.18), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
    }

    private func bookPage(width: CGFloat, height: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 22,
                bottomTrailingRadius: 22,
                topTrailingRadius: 0
            )
                .fill(Color.white)
                .overlay {
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 22,
                        bottomTrailingRadius: 22,
                        topTrailingRadius: 0
                    )
                        .stroke(folder.tint.color.opacity(0.18), lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 10)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            folder.tint.color.opacity(0.22),
                            folder.tint.color.opacity(0.06),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 24)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 22,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 0
                    )
                )

            bookPageContent
                .padding(.leading, 38)
                .padding(.trailing, 24)
                .padding(.top, 38)
        }
        .frame(width: width, height: height)
    }

    private var bookPageContent: some View {
        VStack(alignment: .leading, spacing: 22) {
            if let genre = selectedGenre {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("chapter")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .tracking(1.5)
                            .foregroundColor(folder.tint.color)

                        Text(genre.name.lowercased())
                            .font(.appFont(size: 30, weight: .bold))
                            .foregroundColor(ExilyColors.textPrimary)

                        Text("\(visibleRecipes.count) bookmarked recipes")
                            .font(.appFont(size: 12, weight: .medium))
                            .foregroundColor(ExilyColors.textSecondary)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: genre.symbol)
                        .font(.system(size: 34, weight: .light))
                        .foregroundColor(folder.tint.color.opacity(0.28))
                }
            }

            Rectangle()
                .fill(folder.tint.color.opacity(0.16))
                .frame(height: 1)

            if let featured = visibleRecipes.first {
                VStack(alignment: .leading, spacing: 10) {
                    Text("first bookmark")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .tracking(1.2)
                        .foregroundColor(ExilyColors.textTertiary)

                    Text(featured.title.lowercased())
                        .font(.appFont(size: 22, weight: .bold))
                        .foregroundColor(ExilyColors.textPrimary)

                    Text(featured.subtitle.lowercased())
                        .font(.appFont(size: 13, weight: .medium))
                        .foregroundColor(ExilyColors.textSecondary)

                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                        Text(featured.prepTime.lowercased())
                    }
                    .font(.appFont(size: 12, weight: .semibold))
                    .foregroundColor(folder.tint.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(folder.tint.soft))
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Spacer()

            Text("choose a bookmark to open the recipe")
                .font(.appFont(size: 11, weight: .medium))
                .foregroundColor(ExilyColors.textTertiary)
                .padding(.bottom, 24)
        }
        .animation(.easeInOut(duration: 0.2), value: selectedGenreID)
    }

    private func openRecipe(_ recipe: RecipeDocument) {
        ExilyHaptics.tap(.success)
        AppOrientationController.shared.lock(to: .landscape) {
            selectedRecipe = recipe
        }
    }
}

private struct RecipeBookmark: View {
    let recipe: RecipeDocument
    let tint: CuisineFolder.ColorToken
    let index: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 3) {
                Text(recipe.title.lowercased())
                    .font(.appFont(size: 10.5, weight: .bold))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(recipe.prepTime.lowercased())
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .opacity(0.75)
            }
            .foregroundColor(.white)
            .padding(.leading, 12)
            .padding(.trailing, 20)
            .frame(width: 116, height: 52, alignment: .leading)
            .background(
                BookmarkFlagShape()
                    .fill(tint.color.opacity(max(0.62, 1 - Double(index) * 0.1)))
            )
            .overlay {
                BookmarkFlagShape()
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.12), radius: 5, x: 2, y: 3)
        }
        .buttonStyle(ExilyPressableCardStyle(hapticStrength: .action))
    }
}

private struct BookmarkFlagShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let point = min(13, rect.width * 0.18)
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX - point, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - point, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    NavigationStack {
        CuisineFolderPagesView(folder: MockRecipeData.folders[2])
    }
}
