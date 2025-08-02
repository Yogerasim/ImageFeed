@testable import ImageFeed
import Foundation

final class ImagesListViewMock: ImagesListPresenterDelegate {
    var isReloadCalled = false
    var isErrorShown = false
    var updatedLikeIndex: Int?
    var updatedLikeValue: Bool?
    
    func didUpdatePhotos(insertedIndexPaths: [IndexPath]) {
        isReloadCalled = true
    }
    
    func didFailWithError(_ error: Error) {
        isErrorShown = true
    }

    func updateLikeState(at index: Int, isLiked: Bool) {
        updatedLikeIndex = index
        updatedLikeValue = isLiked
    }
}
