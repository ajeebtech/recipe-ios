import SwiftUI

extension Font {
    static func appFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let fontName: String
        switch weight {
        case .bold, .heavy:
            fontName = "AvenirNext-Bold"
        case .semibold:
            fontName = "AvenirNext-DemiBold"
        case .medium:
            fontName = "AvenirNext-Medium"
        default:
            fontName = "AvenirNext-Regular"
        }
        return Font.custom(fontName, size: size)
    }

    static func artifactMono(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}
