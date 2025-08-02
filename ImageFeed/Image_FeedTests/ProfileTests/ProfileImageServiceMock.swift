import Foundation
@testable import ImageFeed

final class ProfileImageServiceMock: ProfileImageServiceProtocol {
    var fetchAvatarURLCalled = false
    var result: Result<URL, Error>?

    func fetchProfileImageURL(username: String, completion: @escaping (Result<URL, Error>) -> Void) {
        fetchAvatarURLCalled = true
        if let result = result {
            completion(result)
        }
    }
}
