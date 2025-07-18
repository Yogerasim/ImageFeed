import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private let viewModel = ProfileViewModel()
    
    // MARK: - UI Elements
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 35
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 23)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .white
        label.numberOfLines = 0
        label.text = "Hello, world!" // статичный текст
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "logout_button")?.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchProfile()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "ypBlack", in: .main, compatibleWith: traitCollection)
        addSubviews()
        setupConstraints()
        setupActions()
    }
    
    private func addSubviews() {
        [avatarImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func setupActions() {
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }
    
    // MARK: - Bindings
    
    private func bindViewModel() {
        viewModel.onProfileChanged = { [weak self] profile in
            self?.nameLabel.text = profile.name
            self?.loginNameLabel.text = profile.loginName
        }
        
        viewModel.onAvatarChanged = { [weak self] url in
            guard let self = self, let url = url else { return }
            self.avatarImageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "AvatarPlaceholder"),
                options: [
                    .cacheOriginalImage,
                    .transition(.fade(0.2)),
                ]
            )
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapLogoutButton() {
        let alert = UIAlertController(title: "Пока, пока!",
                                      message: "Уверены что хотите выйти?",
                                      preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            OAuth2TokenStorage.shared.token = nil
            
            guard
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let window = windowScene.windows.first
            else {
                print("[ProfileVC] Не удалось получить окно для смены rootViewController")
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            
            guard let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
                print("[ProfileVC] AuthViewController не найден в storyboard")
                return
            }
            
            let nav = UINavigationController(rootViewController: authVC)
            
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }

        let noAction = UIAlertAction(title: "Нет", style: .default)

        alert.addAction(yesAction)
        alert.addAction(noAction)

        present(alert, animated: true)
    }
}
