@testable import ImageFeed

import XCTest

final class WebViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpyMock()
        viewController.presenter = presenter
        presenter.view = viewController

        // When
        _ = viewController.view

        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    
    private func makeTestAuthHelper(configuration: AuthConfiguration) -> AuthHelper {
        return AuthHelper(
            clientId: configuration.accessKey,
            redirectURI: configuration.redirectURI,
            accessScope: configuration.accessScope,
            authURLString: configuration.authURLString
        )
    }
    
    func testPresenterCallsLoadRequest() {
        //Given
        let viewController = WebViewViewControllerSpyMock()
        let configuration = AuthConfiguration.standard
        let authHelper = makeTestAuthHelper(configuration: configuration)
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //When
        presenter.viewDidLoad()
        
        //Then
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        //Given
        let configuration = AuthConfiguration.standard
        let authHelper = makeTestAuthHelper(configuration: configuration)
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        //When
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //Then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        //Given
        let configuration = AuthConfiguration.standard
        let authHelper = makeTestAuthHelper(configuration: configuration)
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        
        //When
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //Then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        //Given
        let configuration = AuthConfiguration.standard
        let authHelper = makeTestAuthHelper(configuration: configuration)
        
        //When
        let url = authHelper.authURL()

        guard let urlString = url?.absoluteString else {
            XCTFail("Auth URL is nil")
            return
        }

        //Then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
        //Given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!
        let configuration = AuthConfiguration.standard
        let authHelper = makeTestAuthHelper(configuration: configuration)
        
        //When
        let code = authHelper.code(from: url)
        
        //Then
        XCTAssertEqual(code, "test code")
    }
    
    
}
