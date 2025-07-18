import Foundation

struct UserResult: Decodable, CustomDebugStringConvertible {
    let profileImage: ProfileImageURLs?

    var debugDescription: String {
        "profileImage.large: \(profileImage?.large?.absoluteString ?? "nil")"
    }
}
