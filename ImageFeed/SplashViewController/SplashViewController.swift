import UIKit

// MARK: - SplashViewController

final class SplashViewController: UIViewController {

    // MARK: - Properties

    private let tokenStorage = OAuth2TokenStorage()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        setupLayout()
        decideNavigationFlow()
    }

    private func setupLayout() {
        view.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Navigation Flow
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "splash_screen_logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private func decideNavigationFlow() {
        if tokenStorage.token != nil {
            fetchProfile()
        } else {
            switchToAuth()
        }
    }

    private func switchToAuth() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("[SplashViewController] ❌ Не удалось получить окно")
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("[SplashViewController] ❌ Не найден AuthViewController")
            return
        }

        authVC.delegate = self
        window.rootViewController = UINavigationController(rootViewController: authVC)
    }

    private func switchToGallery() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("[SplashViewController] ❌ Не удалось получить окно")
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else {
            assertionFailure("[SplashViewController] ❌ Не найден MainTabBarController")
            return
        }

        window.rootViewController = tabBarController
    }

    // MARK: - Profile Fetching

    private func fetchProfile() {
        UIBlockingProgressHUD.show()

        ProfileService.shared.fetchProfile { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()

            switch result {
            case .success(let profile):
                print("[SplashViewController] ✅ Профиль загружен: \(profile.name)")

                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in
                    print("[SplashViewController] 🔄 Загружен avatarURL (или ошибка)")
                }

                self.switchToGallery()

            case .failure(let error):
                print("[SplashViewController] ❌ Ошибка загрузки профиля: \(error.localizedDescription)")
                let alert = UIAlertController(
                    title: "Ошибка",
                    message: "Не удалось загрузить профиль. Попробуйте снова.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Ок", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}
// MARK: - extension
extension UIApplication {
    var keyWindow: UIWindow? {
        (connectedScenes.first as? UIWindowScene)?.windows.first { $0.isKeyWindow }
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)

        fetchProfile()
    }
}
