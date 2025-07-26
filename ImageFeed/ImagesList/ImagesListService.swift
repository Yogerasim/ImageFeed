import UIKit
import Kingfisher

final class ImagesListService {
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    static let shared = ImagesListService()
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var isLoading = false
    private let urlSession = URLSession.shared
    private var isTogglingLike: [String: Bool] = [:]
    
    func fetchPhotosNextPage() {
        guard !isLoading else {
            print("⚠️ Загрузка уже идёт — новый запрос не отправляем.")
            return
        }
        isLoading = true

        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let request = makePhotosRequest(page: nextPage) else {
            print("❌ Не удалось создать URLRequest.")
            isLoading = false
            return
        }

        print("📡 Загружаем страницу \(nextPage)")

        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            defer { self.isLoading = false }

            if let error = error {
                print("❌ Ошибка загрузки фотографий: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ Нет данных от сервера.")
                return
            }

            print("📬 Данные получены от сервера")

            do {
                if let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [Any] {
                    print("📦 Таблица JSON элементов:", jsonArray.count)
                } else {
                    print("⚠️ Не удалось сериализовать JSON как массив.")
                }

                let photoResults = try JSONDecoder.snakeCaseDecoder.decode([PhotoResult].self, from: data)
                print("✅ Декодирование прошло успешно, count = \(photoResults.count)")

                let newPhotos: [Photo] = photoResults.map { result in
                    Photo(
                        id: result.id,
                        size: CGSize(width: result.width, height: result.height),
                        createdAt: result.createdAt,
                        welcomeDescription: result.description,
                        thumbImageURL: result.urls.thumb,
                        largeImageURL: result.urls.full,
                        isLiked: result.likedByUser
                    )
                }

                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    print("✅ Загружено \(newPhotos.count) фото, всего: \(self.photos.count)")
                    NotificationCenter.default.post(name: Self.didChangeNotification, object: nil)
                }

            } catch {
                print("❌ Ошибка декодирования данных: \(error)")
                if let jsonStr = String(data: data, encoding: .utf8) {
                    print("📦 JSON строка:\n\(jsonStr)")
                }
            }
        }

        task.resume()
    }
    
    private func makePhotosRequest(page: Int) -> URLRequest? {
        guard let token = OAuth2TokenStorage.shared.token else {
            print("❌ Нет access token для авторизации.")
            return nil
        }

        var components = URLComponents(string: "https://api.unsplash.com/photos")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10"),
            URLQueryItem(name: "order_by", value: "latest")
        ]

        guard let url = components?.url else {
            print("❌ Не удалось создать URL.")
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func toggleLike(at index: Int, completion: @escaping (Bool) -> Void) {
        let photo = photos[index]
        let photoID = photo.id

        guard isTogglingLike[photoID] != true else {
            print("⏳ Уже идёт переключение лайка для \(photoID)")
            completion(false)
            return
        }

        print("➡️ Отправка toggleLike для фото \(photoID), текущее состояние: \(photo.isLiked)")

        isTogglingLike[photoID] = true
        let newLike = !photo.isLiked
        photos[index].isLiked = newLike

        let method = newLike ? "POST" : "DELETE"
        var request = URLRequest(url: URL(string: "https://api.unsplash.com/photos/\(photoID)/like")!)
        request.httpMethod = method
        request.setValue("Bearer \(OAuth2TokenStorage.shared.token!)", forHTTPHeaderField: "Authorization")

        print("🌐 \(method) запрос на https://api.unsplash.com/photos/\(photoID)/like")

        urlSession.dataTask(with: request) { [weak self] _, response, error in
            defer { self?.isTogglingLike[photoID] = false }

            guard let self else {
                DispatchQueue.main.async { completion(false) }
                return
            }

            if let error = error {
                print("❌ Ошибка ответа от сервера для \(photoID): \(error)")
                DispatchQueue.main.async {
                    self.photos[index].isLiked = !newLike // откат
                    NotificationCenter.default.post(name: Self.didChangeNotification, object: nil)
                    completion(false)
                }
                return
            }

            print("✅ Сервер принял \(method) для \(photoID)")

            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Self.didChangeNotification, object: nil)
                completion(true)
            }
        }.resume()
    }
}

extension ImagesListService {
    func reset(notify: Bool = true, tableView: UITableView? = nil) {
        photos = []
        lastLoadedPage = nil
        isTogglingLike = [:]
        isLoading = false

        print("[ImagesListService] 🧹 Состояние сброшено")

        DispatchQueue.main.async {
            tableView?.reloadData()
        }

        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearDiskCache {
            print("[ImagesListService] 🧹 Кэш изображений Kingfisher очищен")
        }

        if notify {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(name: Self.didChangeNotification, object: nil)
            }
        }
    }
}
