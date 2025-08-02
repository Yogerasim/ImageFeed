import UIKit
@testable import ImageFeed

final class ImagesListServiceMock: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var isFetchNextPageCalled = false
    var isToggleLikeCalled = false
    var toggledIndex: Int?
    var isChangeLikeCalled = false
    var lastChangedPhotoId: String?
    var lastChangedLikeStatus: Bool?
    var changeLikeClosure: ((String, Bool, @escaping (Result<Photo, Error>) -> Void) -> Void)?
    
    func fetchPhotosNextPage(completion: @escaping (Bool) -> Void) {
        isFetchNextPageCalled = true
        completion(true)
    }
    
    func toggleLike(at index: Int, completion: @escaping (Bool) -> Void) {
        isToggleLikeCalled = true
        toggledIndex = index
        if index < photos.count {
            photos[index].isLiked.toggle()
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Photo, Error>) -> Void) {
        isChangeLikeCalled = true
        lastChangedPhotoId = photoId
        lastChangedLikeStatus = isLike

        if let closure = changeLikeClosure {
            closure(photoId, isLike, completion)
            return
        }

        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            photos[index].isLiked = isLike
            completion(.success(photos[index]))
        } else {
            completion(.success(Photo.mock))
        }
    }
    
    func reset(notify: Bool) {
        photos = []
        isFetchNextPageCalled = false
        isToggleLikeCalled = false
        toggledIndex = nil
        isChangeLikeCalled = false
        lastChangedPhotoId = nil
        lastChangedLikeStatus = nil
    }
}

extension Photo {
    static let mock = Photo(
        id: "mock",
        size: CGSize(width: 100, height: 100),
        createdAt: nil,
        welcomeDescription: nil,
        thumbImageURL: "",
        largeImageURL: "",
        isLiked: false
    )
}
