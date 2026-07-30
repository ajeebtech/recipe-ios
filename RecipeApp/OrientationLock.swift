import SwiftUI
import UIKit

final class AppOrientationController {
    static let shared = AppOrientationController()

    private(set) var mask: UIInterfaceOrientationMask = .portrait

    var isLandscape: Bool {
        guard let scene = activeScene else { return false }
        return scene.interfaceOrientation.isLandscape
    }

    private var activeScene: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
            ?? UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
    }

    func lock(to mask: UIInterfaceOrientationMask, then completion: (() -> Void)? = nil) {
        self.mask = mask

        guard let scene = activeScene else {
            completion?()
            return
        }

        scene.requestGeometryUpdate(.iOS(interfaceOrientations: mask)) { _ in
            DispatchQueue.main.async {
                scene.windows.forEach {
                    $0.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                }

                self.waitForOrientation(mask, attempt: 0, then: completion)
            }
        }
    }

    private func waitForOrientation(
        _ mask: UIInterfaceOrientationMask,
        attempt: Int,
        then completion: (() -> Void)?
    ) {
        let ready: Bool = {
            switch mask {
            case .landscape:
                return isLandscape
            case .portrait:
                return !isLandscape
            default:
                return true
            }
        }()

        if ready || attempt >= 12 {
            DispatchQueue.main.asyncAfter(deadline: .now() + (ready ? 0.08 : 0)) {
                completion?()
            }
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            self.waitForOrientation(mask, attempt: attempt + 1, then: completion)
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        AppOrientationController.shared.mask
    }
}

private struct LandscapeRevealModifier: ViewModifier {
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                if AppOrientationController.shared.isLandscape {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        isVisible = true
                    }
                } else {
                    revealWhenReady(attempt: 0)
                }
            }
    }

    private func revealWhenReady(attempt: Int) {
        if AppOrientationController.shared.isLandscape || attempt >= 20 {
            withAnimation(.easeInOut(duration: 0.22)) {
                isVisible = true
            }
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            revealWhenReady(attempt: attempt + 1)
        }
    }
}

extension View {
    func landscapeReveal() -> some View {
        modifier(LandscapeRevealModifier())
    }
}
