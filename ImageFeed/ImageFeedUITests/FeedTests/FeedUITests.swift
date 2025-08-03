import XCTest

final class FeedUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testFeed() throws {
        let table = app.tables.element(boundBy: 0)

        let firstCell = table.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))

        table.swipeUp()
        sleep(1)

        let thirdCell = table.cells.element(boundBy: 2)
        XCTAssertTrue(thirdCell.waitForExistence(timeout: 5))

        let likeButton = firstCell.buttons["LikeButton"]
        XCTAssertTrue(likeButton.exists)

        likeButton.tap()
        sleep(1)
        likeButton.tap()
        sleep(1)

        firstCell.tap()

        let fullImage = app.images["SingleImageView"]
        XCTAssertTrue(fullImage.waitForExistence(timeout: 5))

        fullImage.pinch(withScale: 3, velocity: 1)
        sleep(1)
        fullImage.pinch(withScale: 0.5, velocity: -1)
        sleep(1)

        let backButton = app.buttons["BackButton"]
        XCTAssertTrue(backButton.exists)
        backButton.tap()
    }
}
