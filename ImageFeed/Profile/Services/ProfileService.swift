import Foundation

// MARK: - UI Model

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    let avatarURL: URL?
}

// MARK: - Protocol

protocol ProfileServiceProtocol {
    var profile: Profile? { get }
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void)
}

// MARK: - ProfileService

final class ProfileService: ProfileServiceProtocol {
    static let shared = ProfileService()
    private init() {}

    private let tokenStorage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?

    private(set) var profile: Profile?

    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()

        guard let token = tokenStorage.token else {
            print("[ProfileService] ❌ Токен отсутствует в хранилище")
            completion(.failure(AuthServiceError.tokenMissing))
            return
        }

        guard let url = API.profileURL,
              let request = makeRequest(url: url, token: token)
        else {
            print("[ProfileService] ❌ Неверный URL или не удалось создать запрос")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        print("[ProfileService] 🚀 Запрос профиля с токеном: \(token.prefix(6))...")

        task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            self.task = nil

            switch result {
            case let .success(profileResult):
                let profile = Profile(from: profileResult)
                self.profile = profile

                print("[ProfileService] ✅ Загружен профиль: \(profile.username)")
                DispatchQueue.main.async {
                    completion(.success(profile))
                }

            case let .failure(error):
                print("[ProfileService] ❌ Ошибка при загрузке профиля: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }

        task?.resume()
    }

    private func makeRequest(url: URL, token: String) -> URLRequest? {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")
        return request
    }
}

extension ProfileService {
    func reset() {
        self.profile = nil
        print("[ProfileService] Профиль сброшен")
    }
}
