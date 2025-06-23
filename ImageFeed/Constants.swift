import Foundation

enum Constants {
    // MARK: - API Credentials
    static let accessKey: String = "PxeybXGSEcSOHrstH53cBkNCmyvSCIU_AscydyZAkKk"
    static let secretKey: String = "-puJCYMvRxGPc34HklvWjUHeSbMDED63-oY2xvl9OsI"
    static let redirectURI: String = "urn:ietf:wg:oauth:2.0:oob"

    // MARK: - Access Scope
    static let accessScope: String = "public+read_user+write_likes"

    // MARK: - API Base URL
    static let defaultBaseURL: URL = URL(string: "https://api.unsplash.com")!
}

