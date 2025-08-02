import Foundation

protocol WebViewPresenterProtocol: AnyObject {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL?) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    
    weak var view: WebViewViewControllerProtocol?
    private let authHelper: AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else {
            assertionFailure("Failed to create authorization request")
            return
        }
        view?.load(request: request)
        didUpdateProgressValue(0)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let progress = Float(newValue)
        view?.setProgressValue(progress)
        view?.setProgressHidden(abs(progress - 1.0) <= 0.0001)
    }
    
    func code(from url: URL?) -> String? {
        guard let url = url else { return nil }
        return authHelper.code(from: url)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
            return value >= 1.0
        }
}
