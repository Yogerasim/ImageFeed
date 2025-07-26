import Foundation

struct API {
    static let baseURL = "https://api.unsplash.com"

    static var profileURL: URL? {
        URL(string: "\(baseURL)/me")
    }

    static func userProfileURL(username: String) -> URL? {
        URL(string: "\(baseURL)/users/\(username)")
    }

    static func photoLikeURL(for id: String) -> URL? {
        URL(string: "\(baseURL)/photos/\(id)/like")
    }

    static func photosURL(page: Int, perPage: Int = 10) -> URL? {
        var components = URLComponents(string: "\(baseURL)/photos")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
            URLQueryItem(name: "order_by", value: "latest")
        ]
        return components?.url
    }
}
