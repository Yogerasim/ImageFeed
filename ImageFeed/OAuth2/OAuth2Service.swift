import UIKit
import Foundation

// MARK: - OAuth2Service

final class OAuth2Service {

    // MARK: - Singleton

    static let shared = OAuth2Service()
    private init() {}

    // MARK: - Token Storage

    private let tokenStorage = OAuth2TokenStorage()

    // MARK: - OAuth Request

    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("[OAuth2Service] Не удалось создать baseURL")
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
            print("[OAuth2Service] Не удалось создать URL из URLComponents: \(components)")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }

    // MARK: - Token Fetching

    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service] Ошибка: makeOAuthTokenRequest вернул nil")
            completion(.failure(NetworkError.urlSessionError))
            return
        }

        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder.snakeCaseDecoder.decode(OAuthTokenResponseBody.self, from: data)
                    let token = decoded.accessToken
                    self.tokenStorage.token = token
                    completion(.success(token))
                } catch {
                    print("[OAuth2Service] Ошибка декодирования OAuthTokenResponseBody: \(error.localizedDescription)")
                    completion(.failure(error))
                }

            case .failure(let error):
                print("[OAuth2Service] Ошибка запроса токена: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
