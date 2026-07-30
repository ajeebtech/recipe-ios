import SwiftUI

struct CuisineLibraryView: View {
    @State private var selectedFolder: CuisineFolder?

    private let folders = MockRecipeData.folders

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    ExilyAppHeader(
                        title: "recipe box",
                        subtitle: "\(folders.count) cuisines · tap to open"
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        ExilySectionHeader(title: "Cuisines")
                            .padding(.horizontal, 20)

                        LazyVGrid(
                            columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
                            spacing: 14
                        ) {
                            ForEach(folders) { folder in
                                CuisineFolderCard(folder: folder) {
                                    selectedFolder = folder
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(ExilyColors.background.ignoresSafeArea())
            .navigationDestination(item: $selectedFolder) { folder in
                CuisineFolderPagesView(folder: folder)
            }
        }
    }
}

struct CuisineFolderCard: View {
    let folder: CuisineFolder
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(ExilyColors.surfaceMuted)
                            .frame(width: 40, height: 40)
                        Image(systemName: folder.symbol)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(ExilyColors.textPrimary)
                    }

                    Spacer()

                    ExilyChip(text: "\(folder.recipes.count) pages")
                }

                Text(folder.name.lowercased())
                    .font(.appFont(size: 16, weight: .bold))
                    .foregroundColor(ExilyColors.textPrimary)
                    .lineLimit(1)

                Text("open folder")
                    .font(.appFont(size: 12, weight: .medium))
                    .foregroundColor(ExilyColors.textSecondary)
            }
            .frame(maxWidth: .infinity, minHeight: 118, alignment: .leading)
            .padding(16)
            .background(ExilyColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(ExilyColors.border, lineWidth: 1)
            )
            .exilySoftShadow(radius: 6, y: 3)
        }
        .buttonStyle(ExilyPressableCardStyle(hapticStrength: .action))
    }
}

#Preview {
    CuisineLibraryView()
}
