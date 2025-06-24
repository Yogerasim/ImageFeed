import UIKit

// MARK: - AuthViewController

final class AuthViewController: UIViewController {

    // MARK: - Properties

    private let showWebViewSegueIdentifier = "ShowWebView"

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        navigationController?.navigationBar.tintColor = UIColor(named: "ypBlack") ?? .black
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard let webViewVC = segue.destination as? WebViewViewController else {
                assertionFailure("[AuthVC] WebViewViewController не найден в segue")
                return
            }
            webViewVC.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    // MARK: - UI

    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
    }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    guard
                        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                        let window = windowScene.windows.first
                    else {
                        print("[AuthVC] Не удалось получить окно после авторизации")
                        assertionFailure("Не удалось получить окно")
                        return
                    }

                    let storyboard = UIStoryboard(name: "Main", bundle: .main)
                    guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else {
                        print("[AuthVC] MainTabBarController не найден в storyboard")
                        assertionFailure("Не найден MainTabBarController")
                        return
                    }

                    window.rootViewController = tabBarController

                case .failure(let error):
                    print("[AuthVC] Ошибка получения токена: \(error.localizedDescription)")
                    let alert = UIAlertController(
                        title: "Ошибка",
                        message: "Не удалось войти. Попробуйте снова.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "ОК", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
