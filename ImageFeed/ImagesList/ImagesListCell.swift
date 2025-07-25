import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"

    @IBOutlet private var cellImageView: UIImageView!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var likeButton: UIButton!

    weak var delegate: ImagesListCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        cellImageView.layer.cornerRadius = 10
        cellImageView.clipsToBounds = true
    }

    @IBAction private func likeButtonClicked(_ sender: UIButton) {
        print("❤️ Кнопка лайка нажата (делегатный вызов)")
        delegate?.imageListCellDidTapLike(self)
    }

    func configure(with url: URL?, dateText: String, isLiked: Bool) {
        if let url = url {
            print("📥 Загрузка изображения через Kingfisher: \(url)")
            cellImageView.kf.setImage(with: url) { result in
                switch result {
                case .success:
                    print("✅ Превью успешно загружено")
                case .failure(let error):
                    print("❌ Ошибка загрузки превью: \(error.localizedDescription)")
                }
            }
        } else {
            print("⚠️ URL отсутствует, ставим плейсхолдер")
            cellImageView.image = UIImage(named: "placeholder")
        }

        dateLabel.text = dateText
        setLiked(isLiked)
    }

    func setLiked(_ isLiked: Bool) {
        let imageName = isLiked ? "like_button_on" : "like_button_off"
        likeButton.setImage(UIImage(named: imageName), for: .normal)
    }
}
