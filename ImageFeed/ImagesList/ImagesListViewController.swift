import UIKit

final class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"

    @IBOutlet private var tableView: UITableView!

    private let photoNames: [String] = Array(0 ..< 20).map { "\($0)" }
    
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

            ImagesListService().fetchPhotosNextPage()
    }
    
    @objc private func imagesListDidChange() {
        tableView.reloadData()
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

            let image = UIImage(named: photoNames[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return photoNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        configCell(for: imageListCell, with: indexPath)

        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let image = UIImage(named: photoNames[indexPath.row])
        let dateText = dateFormatter.string(from: Date())
        let isLiked = indexPath.row % 2 == 0

        cell.configure(with: image, dateText: dateText, isLiked: isLiked)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photoNames[indexPath.row]) else { return 0 }

        let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let availableWidth = tableView.bounds.width - insets.left - insets.right

        guard image.size.width != 0 else {
            assertionFailure("Image width is zero, cannot calculate scale.")
            return 0
        }

        let scale = availableWidth / image.size.width
        let height = image.size.height * scale

        return height + insets.top + insets.bottom
    }
}
