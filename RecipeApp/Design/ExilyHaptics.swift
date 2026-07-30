import SwiftUI
import UIKit

enum ExilyHaptics {
    enum Strength {
        case light
        case action
        case select
        case success
    }

    static func tap(_ strength: Strength = .light) {
        switch strength {
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred(intensity: 0.58)
        case .action:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred(intensity: 0.82)
        case .select:
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.success)
        }
    }
}

extension View {
    func exilyHapticOnPress(_ isPressed: Bool, strength: ExilyHaptics.Strength = .light) -> some View {
        onChange(of: isPressed) { _, pressed in
            if pressed { ExilyHaptics.tap(strength) }
        }
    }
}
