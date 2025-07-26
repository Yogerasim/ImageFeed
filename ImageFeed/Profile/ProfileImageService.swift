import Foundation

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    static let DidChangeNotification = Notification.Name("ProfileImageProviderDidChange")

    private init() {}

    private let tokenStorage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?

    private(set) var avatarURL: URL?

    // MARK: - DTO

    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<URL, Error>) -> Void) {
        task?.cancel()

        guard let token = tokenStorage.token else {
            completion(.failure(AuthServiceError.tokenMissing))
            return
        }

        guard let url = API.userProfileURL(username: username) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            self.task = nil

            switch result {
            case let .success(userResult):
                guard let profileImage = userResult.profileImage else {
                    print("[ProfileImageService] ❌ profile_image отсутствует")
                    DispatchQueue.main.async {
                        completion(.failure(AuthServiceError.invalidResponse))
                    }
                    return
                }

                guard let avatarURL = profileImage.large ?? profileImage.medium ?? profileImage.small else {
                    print("[ProfileImageService] ❌ Ни один URL не доступен")
                    DispatchQueue.main.async {
                        completion(.failure(AuthServiceError.invalidResponse))
                    }
                    return
                }

                self.avatarURL = avatarURL
                print("[ProfileImageService] ✅ Загружен avatarURL: \(avatarURL)")

                DispatchQueue.main.async {
                    completion(.success(avatarURL))
                    NotificationCenter.default.post(
                        name: Self.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL]
                    )
                }

            case let .failure(error):
                print("[ProfileImageService] ❌ Ошибка: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }

        task?.resume()
    }
}

extension ProfileImageService {
    func reset() {
        avatarURL = nil
        print("[ProfileImageService] avatarURL сброшен")
    }
}
