import Foundation
@testable import ImageFeed

final class ProfileServiceMock: ProfileServiceProtocol {
    var fetchProfileCalled = false
    var result: Result<Profile, Error>?
    var profile: Profile?

    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        fetchProfileCalled = true
        if let result = result {
            self.profile = try? result.get()
            completion(result)
        }
    }
}

