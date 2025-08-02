import UIKit

protocol ImagesListPresenterDelegate: AnyObject {
    func updateLikeState(at index: Int, isLiked: Bool)
    func didUpdatePhotos(insertedIndexPaths: [IndexPath])
    func didFailWithError(_ error: Error)
}

final class ImagesListPresenter {
    
    weak var delegate: ImagesListPresenterDelegate?
    
    private let imagesListService: ImagesListServiceProtocol
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private(set) var photos: [Photo] = []
    
    
    init(imagesListService: ImagesListServiceProtocol, initialPhotos: [Photo] = []) {
            self.imagesListService = imagesListService
            self.photos = initialPhotos
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(imagesListDidChange),
                name: ImagesListService.didChangeNotification,
                object: nil
            )
        }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func fetchInitialPhotos() {
        imagesListService.reset(notify: false)
        photos = []

        imagesListService.fetchPhotosNextPage { [weak self] success in
            guard let self = self else { return }

            if success {
                let newPhotos = self.imagesListService.photos
                let newCount = newPhotos.count
                self.photos = newPhotos

                let insertedIndexPaths = (0..<newCount).map { IndexPath(row: $0, section: 0) }
                self.delegate?.didUpdatePhotos(insertedIndexPaths: insertedIndexPaths)
            } else {
                self.delegate?.didFailWithError(NSError(domain: "ImageFeed", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch initial photos"]))
            }
        }
    }
    
    @objc private func imagesListDidChange() {
        let oldCount = photos.count
        photos = imagesListService.photos
        let newCount = photos.count
        let insertedCount = newCount - oldCount
        guard insertedCount > 0 else {
            print("[Presenter] No new photos to insert, skipping update")
            return
        }

        let insertedIndexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        delegate?.didUpdatePhotos(insertedIndexPaths: insertedIndexPaths)
    }
    
    func numberOfPhotos() -> Int {
        return photos.count
    }
    
    func photo(at indexPath: IndexPath) -> Photo? {
        guard indexPath.row < photos.count else { return nil }
        return photos[indexPath.row]
    }
    
    func formattedDate(for indexPath: IndexPath) -> String {
        guard let date = photos[indexPath.row].createdAt else { return "" }
        return dateFormatter.string(from: date)
    }
    
    func fetchNextPageIfNeeded(for indexPath: IndexPath) {
        guard indexPath.row == photos.count - 1 else { return }

        let oldCount = photos.count
        imagesListService.fetchPhotosNextPage { [weak self] success in
            guard let self = self else { return }

            if success {
                let newCount = self.imagesListService.photos.count
                let insertedIndexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                print("[Presenter] fetchNextPageIfNeeded — oldCount: \(oldCount), newCount: \(newCount)")
                print("[Presenter] insertedIndexPaths: \(insertedIndexPaths)")
                self.photos = self.imagesListService.photos
                self.delegate?.didUpdatePhotos(insertedIndexPaths: insertedIndexPaths)
            } else {
                self.delegate?.didFailWithError(NSError(domain: "ImageFeed", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch next page"]))
            }
        }
    }
    
    func toggleLike(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        guard indexPath.row < photos.count else {
            completion(false)
            return
        }
        
        let photo = photos[indexPath.row]
        let newLikeState = !photo.isLiked
        
        imagesListService.changeLike(photoId: photo.id, isLike: newLikeState) { [weak self] result in
            switch result {
            case .success(let updatedPhoto):
                self?.photos[indexPath.row] = updatedPhoto
                self?.delegate?.updateLikeState(at: indexPath.row, isLiked: updatedPhoto.isLiked)
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
}
