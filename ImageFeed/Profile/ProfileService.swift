import Foundation

// MARK: - ProfileImageURLs

struct ProfileImageURLs: Codable {
    let small: URL?
    let medium: URL?
    let large: URL?
}

// MARK: - ProfileResult DTO from Unsplash

struct ProfileResult: Codable, CustomDebugStringConvertible {
    let username: String?
    let firstName: String?
    let lastName: String?
    let bio: String?
    let profileImage: ProfileImageURLs?

    var debugDescription: String {
        """
        username: \(username ?? "nil")
        firstName: \(firstName ?? "nil")
        lastName: \(lastName ?? "nil")
        bio: \(bio ?? "nil")
        profileImage.large: \(profileImage?.large?.absoluteString ?? "nil")
        """
    }
}

// MARK: - UI Model

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    let avatarURL: URL?
}

// MARK: - ProfileService

final class ProfileService {

    static let shared = ProfileService()
    private init() {}

    private let tokenStorage = OAuth2TokenStorage()
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

        guard let url = URL(string: "https://api.unsplash.com/me"),
              let request = makeRequest(url: url, token: token) else {
            print("[ProfileService] ❌ Неверный URL или не удалось создать запрос")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        print("[ProfileService] 🚀 Запрос профиля с токеном: \(token.prefix(6))... (обрезан)")

        task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            self.task = nil

            switch result {
            case .success(let profileResult):
                print("[DEBUG] 📄 profileResult: \(profileResult.debugDescription)")
                let profile = Profile(
                    username: profileResult.username ?? "",
                    name: "\(profileResult.firstName ?? "") \(profileResult.lastName ?? "")".trimmingCharacters(in: .whitespaces),
                    loginName: "@\(profileResult.username ?? "")",
                    bio: profileResult.bio,
                    avatarURL: profileResult.profileImage?.large
                )

                self.profile = profile

                print("[ProfileService] ✅ Загружен профиль: \(profile.username)")
                print("[ProfileService] ✅ avatarURL: \(profile.avatarURL?.absoluteString ?? "nil")")

                DispatchQueue.main.async {
                    completion(.success(profile))
                }

            case .failure(let error):
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
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")
        return request
    }
}
