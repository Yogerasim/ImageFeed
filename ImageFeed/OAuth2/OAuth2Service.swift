import Foundation

// MARK: - AuthServiceError

enum AuthServiceError: Error {
    case invalidRequest
    case invalidResponse
    case decodingError
    case tokenMissing
}



// MARK: - OAuth2Service

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private init() {}

    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage()

    private var task: URLSessionTask?
    private var lastCode: String?

    // MARK: - Public API

    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)

        if let task = task {
            if lastCode != code {
                print("[OAuth2Service] 🔁 Отменяем предыдущий запрос с кодом: \(lastCode ?? "nil")")
                task.cancel()
            } else {
                print("[OAuth2Service] ⚠️ Повторный запрос с тем же кодом: \(code)")
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else if lastCode == code {
            print("[OAuth2Service] ⚠️ Повторный код при пустом task: \(code)")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        lastCode = code
        print("[OAuth2Service] 🚀 Начинаем запрос токена с кодом: \(code)")

        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service] ❌ Не удалось создать запрос")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                self?.task = nil
                self?.lastCode = nil

                switch result {
                case .success(let decoded):
                    let token = decoded.accessToken
                    print("[OAuth2Service] ✅ Получен токен: \(token.prefix(6))... (обрезан)")
                    self?.tokenStorage.token = token
                    completion(.success(token))

                case .failure(let error):
                    print("[OAuth2Service] ❌ Ошибка получения токена: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }

        self.task = task
        task.resume()
    }

    // MARK: - Request Builder

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("[OAuth2Service] ❌ baseURL невалиден")
            return nil
        }

        var components = URLComponents()
        components.path = "/oauth/token"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        guard let url = components.url(relativeTo: baseURL) else {
            print("[OAuth2Service] ❌ Не удалось собрать URL из компонентов")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
