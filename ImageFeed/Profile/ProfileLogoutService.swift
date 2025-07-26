import Foundation
import WebKit
import UIKit
import Kingfisher

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()

    private init() {}

    func logout() {
        print("[LogoutService] 🚪 Начат выход из аккаунта")
        clearToken()
        clearCookies()
        clearProfileData()
        switchToAuthScreen()
    }

    private func clearToken() {
        OAuth2TokenStorage.shared.token = nil
        print("[LogoutService] 🧹 Токен удалён")
    }

    private func clearCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        URLCache.shared.removeAllCachedResponses()

        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }

        print("[LogoutService] 🍪 Куки и веб-данные очищены")
    }

    private func clearProfileData() {
        ProfileService.shared.reset()
        ProfileImageService.shared.reset()

        // Попытка найти контроллер и сразу очистить его таблицу
        if let tabBarVC = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController,
           let nav = tabBarVC.viewControllers?.first as? UINavigationController {
            
            for vc in nav.viewControllers {
                if let imagesVC = vc as? ImagesListViewController {
                    ImagesListService.shared.reset(tableView: imagesVC.exposedTableView)
                    break
                }
            }
        } else {
            ImagesListService.shared.reset()
        }

        // Очистка изображений Kingfisher
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearDiskCache {
            print("[LogoutService] 🧼 Кэш Kingfisher очищен")
        }

        print("[LogoutService] 🧽 Все пользовательские данные очищены")
    }

    private func switchToAuthScreen() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("[LogoutService] ❌ Не удалось получить окно")
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            print("[LogoutService] ❌ AuthViewController не найден")
            return
        }

        let nav = UINavigationController(rootViewController: authVC)
        window.rootViewController = nav
        window.makeKeyAndVisible()

        print("[LogoutService] 🔄 Переключено на AuthViewController")
    }
}
