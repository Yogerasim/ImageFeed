import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImageView: UIImageView!
        @IBOutlet weak var dateLabel: UILabel!
        @IBOutlet weak var likeButton: UIButton!
    
    func setLiked(_ isLiked: Bool) {
        let imageName = isLiked ? "like_button_on" : "like_button_off"
        likeButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellImageView.layer.cornerRadius = 10
        cellImageView.clipsToBounds = true
    }
    

}
