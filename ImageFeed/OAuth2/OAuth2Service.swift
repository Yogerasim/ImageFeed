import UIKit
import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}

    private let tokenStorage = OAuth2TokenStorage()

    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else { return nil }

        var components = URLComponents()
        components.path = "/oauth/token"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        guard let url = components.url(relativeTo: baseURL) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }

    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }

        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    let token = decoded.accessToken
                    self.tokenStorage.token = token
                    completion(.success(token))
                } catch {
                    print("Ошибка декодирования токена: \(error)")
                    completion(.failure(error))
                }

            case .failure(let error):
                print("Ошибка сети при получении токена: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

