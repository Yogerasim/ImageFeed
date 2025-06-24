import Foundation
import UIKit

// MARK: - OAuthTokenResponseBody

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
}

// MARK: - OAuth2TokenStorage

final class OAuth2TokenStorage {
    private let tokenKey = "OAuthToken"

    var token: String? {
        get {
            let value = UserDefaults.standard.string(forKey: tokenKey)
            if value == nil {
                print("[OAuth2TokenStorage] Токен не найден в UserDefaults")
            }
            return value
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: tokenKey)
            print("[OAuth2TokenStorage] Токен сохранён в UserDefaults")
        }
    }
}
