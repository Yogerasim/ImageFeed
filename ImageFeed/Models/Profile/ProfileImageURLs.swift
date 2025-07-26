import Foundation

struct ProfileImageURLs: Decodable {
    let small: URL?
    let medium: URL?
    let large: URL?
}

extension ProfileImageURLs {
    init(from result: UserResult) {
        self = result.profileImage ?? ProfileImageURLs(small: nil, medium: nil, large: nil)
    }
}
