import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
    func reloadTableView()
    func showError(_ error: Error)
    func updateLikeState(at index: Int, isLiked: Bool)
}

final class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"

    @IBOutlet private var tableView: UITableView!
    public var exposedTableView: UITableView? { tableView }

    private lazy var presenter = ImagesListPresenter(
        imagesListService: ImagesListService.shared)

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        presenter.delegate = self
        presenter.fetchInitialPhotos()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.fetchInitialPhotos()
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier,
           let viewController = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath,
           let photo = presenter.photo(at: indexPath) {
            viewController.imageURL = URL(string: photo.largeImageURL)
        }
    }
}

extension ImagesListViewController: ImagesListPresenterDelegate {
    
    func didUpdatePhotos(insertedIndexPaths: [IndexPath]) {
        let currentRows = tableView.numberOfRows(inSection: 0)
        let maxInsertedIndex = insertedIndexPaths.map { $0.row }.max() ?? -1
        guard maxInsertedIndex >= currentRows else {
            print("[ViewController] Ignoring invalid insertions: maxInsertedIndex < currentRows")
            tableView.reloadData() 
            return
        }

        guard !insertedIndexPaths.isEmpty else {
            tableView.reloadData()
            return
        }

        tableView.performBatchUpdates {
            tableView.insertRows(at: insertedIndexPaths, with: .automatic)
        }
    }

    func didFailWithError(_ error: Error) {
        print("Ошибка загрузки фото: \(error)")
    }
    
    func updateLikeState(at index: Int, isLiked: Bool) {
        let indexPath = IndexPath(row: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfPhotos()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell,
              let photo = presenter.photo(at: indexPath)
        else {
            return UITableViewCell()
        }

        let dateText = presenter.formattedDate(for: indexPath)
        let url = URL(string: photo.thumbImageURL)

        imageListCell.configure(with: url, dateText: dateText, isLiked: photo.isLiked)
        imageListCell.delegate = self

        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter.photo(at: indexPath) else { return 200 }
        let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let availableWidth = tableView.bounds.width - insets.left - insets.right
        let scale = availableWidth / photo.size.width
        return photo.size.height * scale + insets.top + insets.bottom
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.fetchNextPageIfNeeded(for: indexPath)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("❌ Не удалось получить indexPath для нажатой ячейки")
            return
        }

        UIBlockingProgressHUD.show()
        presenter.toggleLike(at: indexPath) { [weak self] success in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                if let updatedPhoto = self?.presenter.photo(at: indexPath) {
                    cell.setLiked(updatedPhoto.isLiked)
                }
            }
        }
    }
}
