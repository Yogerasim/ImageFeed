import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {

    // MARK: - UI Elements

    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let logoutButton = UIButton()

    // MARK: - Lifecycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        addObserver()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addObserver()
    }

    deinit {
        removeObserver()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1.0)
        setupUI()

        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
        } else {
            ProfileService.shared.fetchProfile { [weak self] result in
                switch result {
                case .success(let profile):
                    DispatchQueue.main.async {
                        self?.updateProfileDetails(profile: profile)
                        ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                    }
                case .failure(let error):
                    print("[ProfileViewController] ❌ Ошибка загрузки профиля: \(error.localizedDescription)")
                }
            }
        }

        if let avatarURL = ProfileImageService.shared.avatarURL {
            updateAvatarImage(with: avatarURL)
        }
    }

    // MARK: - Observers

    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAvatar(notification:)),
            name: ProfileImageService.didChangeNotification,
            object: nil
        )
    }

    private func removeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: ProfileImageService.didChangeNotification,
            object: nil
        )
    }

    @objc private func updateAvatar(notification: Notification) {
        guard isViewLoaded else {
            print("[ProfileViewController] ⚠️ View не загружен")
            return
        }

        if let userInfo = notification.userInfo {
            print("[ProfileViewController] 📨 Получено userInfo: \(userInfo)")

            if let avatarURL = userInfo["URL"] as? URL {
                updateAvatarImage(with: avatarURL)
            } else {
                print("[ProfileViewController] ❌ 'URL' не является URL: \(type(of: userInfo["URL"] ?? "nil")) — значение: \(userInfo["URL"] ?? "nil")")
            }
        } else {
            print("[ProfileViewController] ❌ userInfo отсутствует")
        }
    }

    private func updateAvatarImage(with url: URL) {
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "Avatar"),
            options: [
                .cacheOriginalImage,
                .transition(.fade(0.2))
            ]) { result in
                switch result {
                case .success:
                    print("[ProfileViewController] ✅ Аватарка загружена через Kingfisher")
                case .failure(let error):
                    print("[ProfileViewController] ❌ Ошибка загрузки через Kingfisher: \(error.localizedDescription)")
                }
            }
    }

    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = "\(profile.loginName)"
        descriptionLabel.text = "Hello, world!" // Статичный текст
    }
}

// MARK: - UI Setup

private extension ProfileViewController {

    func setupUI() {
        setupAvatarImageView()
        setupNameLabel()
        setupLoginNameLabel()
        setupDescriptionLabel()
        setupLogoutButton()
    }

    func setupAvatarImageView() {
        avatarImageView.image = UIImage(named: "Avatar") // Заглушка
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 35
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)

        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }

    func setupNameLabel() {
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor, constant: -4),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8)
        ])
    }

    func setupLoginNameLabel() {
        loginNameLabel.font = UIFont.systemFont(ofSize: 13)
        loginNameLabel.textColor = .gray
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)

        NSLayoutConstraint.activate([
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
    }

    func setupDescriptionLabel() {
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8)
        ])
    }

    func setupLogoutButton() {
        logoutButton.setImage(UIImage(named: "logout_button"), for: .normal)
        logoutButton.tintColor = .red
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        view.addSubview(logoutButton)

        NSLayoutConstraint.activate([
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }

    @objc func didTapLogoutButton() {
        tabBarController?.selectedIndex = 0
    }
}
