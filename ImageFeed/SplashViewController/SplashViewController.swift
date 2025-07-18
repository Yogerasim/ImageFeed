import UIKit

// MARK: - SplashViewController

final class SplashViewController: UIViewController {
    // MARK: - Properties

    private let tokenStorage = OAuth2TokenStorage.shared

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        decideNavigationFlow()
    }

    // MARK: - Navigation Flow

    private func decideNavigationFlow() {
        guard tokenStorage.token != nil else {
            switchToAuth()
            return
        }
        fetchProfile()
    }

    private func switchToAuth() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else {
            assertionFailure("[SplashViewController] ❌ Не удалось получить окно")
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("[SplashViewController] ❌ Не найден AuthViewController")
            return
        }

        authVC.delegate = self
        window.setRootViewController(UINavigationController(rootViewController: authVC))
    }

    private func switchToGallery() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else {
            assertionFailure("[SplashViewController] ❌ Не удалось получить окно")
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else {
            assertionFailure("[SplashViewController] ❌ Не найден MainTabBarController")
            return
        }
        window.setRootViewController(tabBarController)
    }

    // MARK: - Profile Fetching

    private func fetchProfile() {
        UIBlockingProgressHUD.show()

        ProfileService.shared.fetchProfile { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()

            switch result {
            case let .success(profile):
                print("[SplashViewController] ✅ Профиль загружен: \(profile.name)")

                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in
                    print("[SplashViewController] 🔄 Загружен avatarURL (или ошибка)")
                }

                self.switchToGallery()

            case let .failure(error):
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

    // MARK: - UI Setup

    private func setupView() {
        view.backgroundColor = UIColor(named: "ypBlack", in: .main, compatibleWith: traitCollection)
    }

    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "splash_screen_logo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private func setupLayout() {
        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 73),
            logoImageView.heightAnchor.constraint(equalToConstant: 75),
        ])
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
