import XCTest

final class AuthUITests: XCTestCase {

    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments += ["--ui-testing"]
        app.launchEnvironment["isMockAuth"] = "true"
        app.launch()
    }

    func testAuthFlow_withMock() throws {
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5), "Кнопка авторизации не найдена")
        authButton.tap()
        
        let webView = app.webViews.firstMatch
        XCTAssertTrue(webView.waitForExistence(timeout: 5), "WebView не появился")

        _ = URL(string: "https://unsplash.com/oauth/authorize/native?code=test-code")!

        let webViewVC = XCUIApplication().windows.firstMatch
        XCTAssertTrue(webViewVC.exists)

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10), "TabBar не появился — авторизация не завершена")

        XCTAssertTrue(app.buttons["NoActiveScroll"].exists || app.buttons["ActiveScroll"].exists)
        XCTAssertTrue(app.buttons["NoActiveProfile"].exists || app.buttons["ActiveProfile"].exists)
    }
    
    func testAuthFlow_withRealLogin() {
        let app = XCUIApplication()
        app.launch()

        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        authButton.tap()

        let webView = app.webViews.element
        XCTAssertTrue(webView.waitForExistence(timeout: 10))

        let emailTextField = webView.textFields.element(boundBy: 0)
        XCTAssertTrue(emailTextField.waitForExistence(timeout: 5))
        emailTextField.tap()
        emailTextField.typeText("filipgerasim988@gmail.com")

        let passwordSecureField = webView.secureTextFields.element(boundBy: 0)
        XCTAssertTrue(passwordSecureField.waitForExistence(timeout: 5))
        passwordSecureField.tap()
        passwordSecureField.typeText("Philipp000")

        let loginButton = webView.buttons["Authorize"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()

        let imagesListCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(imagesListCell.waitForExistence(timeout: 10))
    }
}
