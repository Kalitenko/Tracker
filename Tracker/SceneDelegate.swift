import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let hasSeenOnboarding = OnboardingStorage.shared.hasSeenOnboarding

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let rootController: UIViewController
        if hasSeenOnboarding {
            rootController = TabBarController()
        } else {
            rootController = OnboardingPageViewController()
        }
        window?.rootViewController = rootController
        window?.makeKeyAndVisible()
    }
}
