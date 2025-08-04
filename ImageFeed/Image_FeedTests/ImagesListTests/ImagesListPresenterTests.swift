import XCTest
@testable import ImageFeed

final class ImagesListPresenterTests: XCTestCase {

    func testFetchPhotosNextPage_CallsServiceAndReloadsView() {
        // Given: A mock service and view with a presenter
        let service = ImagesListServiceMock()
        let view = ImagesListViewMock()
        let presenter = ImagesListPresenter(imagesListService: service)
        presenter.delegate = view

        // When: Fetching initial photos
        presenter.fetchInitialPhotos()

        // Then: Service and view are triggered
        XCTAssertTrue(service.isFetchNextPageCalled, "Service should call fetchPhotosNextPage")
        XCTAssertTrue(view.isReloadCalled, "View should reload the table")
    }

    func testToggleLikeUpdatesPhotosArray() {
        // Given: One photo in mocked service
        let photoId = "123"
        let initialPhoto = Photo(
            id: photoId,
            size: CGSize(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "thumb_url",
            largeImageURL: "large_url",
            isLiked: false
        )

        let mockService = ImagesListServiceMock()
        mockService.photos = [initialPhoto]
        let presenter = ImagesListPresenter(imagesListService: mockService, initialPhotos: mockService.photos)

        let expectation = expectation(description: "Toggle like completes")

        // When: Toggling like on photo
        presenter.toggleLike(at: IndexPath(row: 0, section: 0)) { success in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        // Then: Photo is marked as liked
        let updatedPhoto = mockService.photos.first(where: { $0.id == photoId })
        XCTAssertNotNil(updatedPhoto)
        XCTAssertTrue(updatedPhoto?.isLiked == true)
    }
}
