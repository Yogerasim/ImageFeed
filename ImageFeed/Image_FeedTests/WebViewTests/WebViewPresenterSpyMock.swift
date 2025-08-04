import Foundation
import WebKit
@testable import ImageFeed

final class WebViewPresenterSpyMock: WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol?

    var viewDidLoadCalled = false
    var updatedProgress: Double?
    var receivedURLForCode: URL?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didUpdateProgressValue(_ newValue: Double) {
        updatedProgress = newValue
    }

    func code(from url: URL?) -> String? {
        receivedURLForCode = url
        return nil
    }
}
