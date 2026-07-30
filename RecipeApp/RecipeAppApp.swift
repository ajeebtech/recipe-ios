import SwiftUI

@main
struct RecipeAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            CuisineLibraryView()
        }
    }
}
