import UIKit
@testable import ImageFeed

final class TestAuthHelper: AuthHelperProtocol {
    func authRequest() -> URLRequest? {
        return URLRequest(url: URL(string: "https://example.com/fake-auth")!)
    }

    func code(from url: URL) -> String? {
        return "test-code"
    }
}
