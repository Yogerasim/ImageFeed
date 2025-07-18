import Foundation

struct ProfileResult: Decodable {
    let username: String?
    let firstName: String?
    let lastName: String?
    let bio: String?
    let profileImage: ProfileImageURLs?

    var debugDescription: String {
        """
        username: \(username ?? "nil")
        firstName: \(firstName ?? "nil")
        lastName: \(lastName ?? "nil")
        bio: \(bio ?? "nil")
        profileImage.large: \(profileImage?.large?.absoluteString ?? "nil")
        """
    }
}
