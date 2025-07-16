import Foundation
import SwiftKeychainWrapper

// MARK: - OAuthTokenResponseBody

struct OAuthTokenResponseBody: Codable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

// MARK: - OAuth2TokenStorage

final class OAuth2TokenStorage {
    private let tokenKey = "OAuthToken"

    var token: String? {
        get {
            guard let token = KeychainWrapper.standard.string(forKey: tokenKey) else {
                print("[OAuth2TokenStorage] ❌ Токен не найден в Keychain")
                return nil
            }

            print("[OAuth2TokenStorage] ✅ Токен получен из Keychain")
            return token
        }
        set {
            guard let token = newValue else {
                let success = KeychainWrapper.standard.removeObject(forKey: tokenKey)
                print("[OAuth2TokenStorage] \(success ? "🗑 Удалён" : "❌ Не удалось удалить") токен из Keychain")
                return
            }

            let success = KeychainWrapper.standard.set(token, forKey: tokenKey)
            print("[OAuth2TokenStorage] \(success ? "✅" : "❌") Сохранение токена в Keychain")
        }
    }
}
