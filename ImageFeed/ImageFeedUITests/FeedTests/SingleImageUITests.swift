import XCTest

final class SingleImageUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testSingleImageZoomAndBack() throws {
        
        let scrollView = app.scrollViews["SingleImageScrollView"]
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), "ScrollView не найден")

        let imageView = app.images["SingleImageView"]
        XCTAssertTrue(imageView.exists, "ImageView не найден")

        imageView.pinch(withScale: 3.0, velocity: 1.0)

        imageView.pinch(withScale: 0.5, velocity: -1.0)

        let backButton = app.buttons["nav back button white"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Кнопка назад не найдена")
        backButton.tap()
    }
}
