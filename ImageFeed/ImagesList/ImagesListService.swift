import UIKit

final class ImagesListService {
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var isLoading = false
    private let urlSession = URLSession.shared
    
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

            guard
                let data = data,
                let photoResults = try? JSONDecoder.snakeCaseDecoder.decode([PhotoResult].self, from: data)
            else {
                print("❌ Ошибка декодирования данных.")
                return
            }

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
            URLQueryItem(name: "per_page", value: "10")
        ]

        guard let url = components?.url else {
            print("❌ Не удалось создать URL.")
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
