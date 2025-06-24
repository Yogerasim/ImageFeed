import UIKit

// MARK: - SplashViewController

final class SplashViewController: UIViewController {

    // MARK: - Properties

    private let tokenStorage = OAuth2TokenStorage()

    // MARK: - Lifecycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        decideNavigationFlow()
    }

    // MARK: - Navigation Flow

    private func decideNavigationFlow() {
        if let _ = tokenStorage.token {
            switchToGallery()
        } else {
            switchToAuth()
        }
    }

    private func switchToAuth() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            print("[SplashViewController] Не удалось получить windowScene")
            assertionFailure("Не удалось получить windowScene")
            return
        }

        guard let window = windowScene.windows.first else {
            print("[SplashViewController] Не удалось получить окно из windowScene")
            assertionFailure("Не удалось получить окно")
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            print("[SplashViewController] Не удалось найти AuthViewController по идентификатору")
            assertionFailure("Не найден AuthViewController")
            return
        }

        window.rootViewController = UINavigationController(rootViewController: authVC)
    }

    private func switchToGallery() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            print("[SplashViewController] Не удалось получить windowScene")
            assertionFailure("Не удалось получить windowScene")
            return
        }

        guard let window = windowScene.windows.first else {
            print("[SplashViewController] Не удалось получить окно из windowScene")
            assertionFailure("Не удалось получить окно")
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else {
            print("[SplashViewController] Не удалось найти MainTabBarController по идентификатору")
            assertionFailure("Не найден MainTabBarController")
            return
        }

        window.rootViewController = tabBarController
    }
}
