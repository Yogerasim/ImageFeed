import Foundation

// MARK: - Constants

enum Constants {
    
    static let accessKey: String = "PxeybXGSEcSOHrstH53cBkNCmyvSCIU_AscydyZAkKk"
    static let secretKey: String = "-puJCYMvRxGPc34HklvWjUHeSbMDED63-oY2xvl9OsI"
    static let redirectURI: String = "urn:ietf:wg:oauth:2.0:oob"

    // MARK: - Access Scope

    static let accessScope: String = "public+read_user+write_likes"

    // MARK: - API Base URL

    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            print("[Constants] Не удалось создать defaultBaseURL")
            assertionFailure("Invalid API base URL")
            return URL(fileURLWithPath: "/dev/null")
        }
        return url
    }()
}
