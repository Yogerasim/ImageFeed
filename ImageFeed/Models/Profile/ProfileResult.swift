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

extension Profile {
    init(from result: ProfileResult) {
        self.username = result.username ?? ""
        self.name = "\(result.firstName ?? "") \(result.lastName ?? "")".trimmingCharacters(in: .whitespaces)
        self.loginName = "@\(result.username ?? "")"
        self.bio = result.bio
        self.avatarURL = result.profileImage?.large
    }
}
