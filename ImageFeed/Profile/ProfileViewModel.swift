import Foundation

final class ProfileViewModel {

    var onProfileChanged: ((Profile) -> Void)?
    var onAvatarChanged: ((URL?) -> Void)?

    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol

    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        observeAvatarChanges()
    }

    func fetchProfile() {
        profileService.fetchProfile { [weak self] result in
            switch result {
            case let .success(profile):
                self?.onProfileChanged?(profile)
                self?.onAvatarChanged?(profile.avatarURL)
            case let .failure(error):
                print("[ViewModel] ❌ Ошибка загрузки профиля: \(error)")
            }
        }
    }

    private func observeAvatarChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAvatarUpdate(_:)),
            name: ProfileImageService.didChangeNotification,
            object: nil
        )
    }

    @objc private func handleAvatarUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let url = userInfo["URL"] as? URL else {
            print("[ViewModel] ❌ userInfo или URL отсутствует")
            return
        }

        print("[ViewModel] 🖼 avatarURL обновлён: \(url.absoluteString)")
        onAvatarChanged?(url)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
