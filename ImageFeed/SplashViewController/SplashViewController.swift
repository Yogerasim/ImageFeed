import UIKit

final class SplashViewController: UIViewController {

    private let tokenStorage = OAuth2TokenStorage()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        decideNavigationFlow()
    }

    private func decideNavigationFlow() {
        if let _ = tokenStorage.token {
            switchToGallery()
        } else {
            switchToAuth()
        }
    }

    private func switchToAuth() {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first
        else {
            assertionFailure("Не удалось получить окно")
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authVC = storyboard.instantiateViewController(identifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("Не найден AuthViewController")
            return
        }

        window.rootViewController = UINavigationController(rootViewController: authVC)
    }

    private func switchToGallery() {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first
        else {
            assertionFailure("Не удалось получить окно")
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else {
            assertionFailure("Не найден MainTabBarController")
            return
        }

        window.rootViewController = tabBarController
    }
}
