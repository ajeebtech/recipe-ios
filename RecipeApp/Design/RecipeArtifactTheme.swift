import SwiftUI

/// Visual tokens from artifact.html — clean technical-manual recipe diagram.
enum ArtifactColors {
    static let background = Color(red: 0.949, green: 0.953, blue: 0.957)   // #f2f3f4
    static let card = Color.white
    static let ink = Color(red: 0.082, green: 0.090, blue: 0.102)           // #15171a
    static let ink2 = Color(red: 0.353, green: 0.376, blue: 0.412)          // #5a6069
    static let ink3 = Color(red: 0.435, green: 0.459, blue: 0.494)          // #6f757e
    static let ink4 = Color(red: 0.525, green: 0.553, blue: 0.584)        // #868d95
    static let rule = Color(red: 0.863, green: 0.867, blue: 0.882)          // #dcdee1
    static let rule2 = Color(red: 0.761, green: 0.773, blue: 0.792)       // #c2c5ca
    static let band = Color(red: 0.973, green: 0.976, blue: 0.980)        // #f8f9fa
    static let accent = Color(red: 0.059, green: 0.478, blue: 0.275)      // #0f7a46
    static let accent2 = Color(red: 0.043, green: 0.373, blue: 0.212)    // #0b5f36
    static let accentSoft = Color(red: 0.914, green: 0.957, blue: 0.933)  // #e9f4ee
    static let accentLine = Color(red: 0.612, green: 0.796, blue: 0.698)  // #9ccbb2
    static let segBackground = Color(red: 0.906, green: 0.914, blue: 0.922) // #e7e9eb
}

enum ArtifactMetrics {
    static let operationColumnWidth: CGFloat = 106
    static let ingredientColumnWidth: CGFloat = 280
}
