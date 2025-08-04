import Foundation
import WebKit
@testable import ImageFeed

final class WebViewViewControllerSpyMock: WebViewViewControllerProtocol {
    
    var presenter: ImageFeed.WebViewPresenterProtocol?

    var loadRequestCalled: Bool = false

    func load(request: URLRequest) {
        loadRequestCalled = true
    }

    func setProgressValue(_ newValue: Float) {

    }

    func setProgressHidden(_ isHidden: Bool) {

    }
}
