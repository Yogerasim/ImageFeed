import XCTest

final class ProfileUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }

    func testProfile() throws {
        
        sleep(3)
        
        app.tabBars.buttons.element(boundBy: 1).tap()

        XCTAssertTrue(app.staticTexts["ProfileNameLabel"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["ProfileLoginLabel"].waitForExistence(timeout: 5))

        let logoutButton = app.buttons["ProfileLogoutButton"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        logoutButton.tap()

        let alert = app.alerts["Пока, пока!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.scrollViews.otherElements.buttons["Да"].tap()

        XCTAssertTrue(app.buttons["LoginButton"].waitForExistence(timeout: 5))
    }
}
