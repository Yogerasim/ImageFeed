import UIKit

final class ImagesListViewController: UIViewController, ImagesListCellDelegate {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"

    @IBOutlet private var tableView: UITableView!
    
    public var exposedTableView: UITableView? {
        return tableView
    }
    
    private let imagesListService = ImagesListService()

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(imagesListDidChange),
            name: ImagesListService.didChangeNotification,
            object: nil
        )

        imagesListService.fetchPhotosNextPage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        ImagesListService.shared.reset(notify: false)
        tableView.reloadData()
        ImagesListService.shared.fetchPhotosNextPage()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func imagesListDidChange() {
        print("📣 imagesListDidChange (с анимацией)")
        updateTableViewAnimated()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            let photo = imagesListService.photos[indexPath.row]
            viewController.imageURL = URL(string: photo.largeImageURL)
        }
    }
    private func updateTableViewAnimated() {
        let oldCount = tableView.numberOfRows(inSection: 0)
        let newCount = imagesListService.photos.count
        let addedCount = newCount - oldCount

        guard addedCount > 0 else {
            print("📭 Нет новых строк для вставки.")
            return
        }

        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }

        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagesListService.photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("🧱 Создаётся ячейка для строки \(indexPath.row)")

        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            print("❌ Ошибка кастинга ячейки в ImagesListCell")
            return UITableViewCell()
        }

        let photo = imagesListService.photos[indexPath.row]
        let dateText = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        let url = URL(string: photo.thumbImageURL)

        imageListCell.configure(with: url, dateText: dateText, isLiked: photo.isLiked)
        imageListCell.delegate = self

        return imageListCell
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = imagesListService.photos[indexPath.row]
        let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let availableWidth = tableView.bounds.width - insets.left - insets.right
        let scale = availableWidth / photo.size.width
        return photo.size.height * scale + insets.top + insets.bottom
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == imagesListService.photos.count - 1 {
            print("🌀 Последняя ячейка — подгружаем следующую страницу...")
            imagesListService.fetchPhotosNextPage()
        }
    }

    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("❌ Не удалось получить indexPath для нажатой ячейки")
            return
        }

        let photo = imagesListService.photos[indexPath.row]
        UIBlockingProgressHUD.show()

        imagesListService.toggleLike(at: indexPath.row) { [weak self] success in
            guard let self else { return }
            let updatedPhoto = imagesListService.photos[indexPath.row]
            DispatchQueue.main.async {
                cell.setLiked(updatedPhoto.isLiked)
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}
