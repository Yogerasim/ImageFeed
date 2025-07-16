import UIKit

final class MainTabBarController: UITabBarController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        let profileViewController = ProfileViewController()
        
        imagesListViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "NoActiveScroll")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "ActiveScroll")?.withRenderingMode(.alwaysOriginal)
        )
        
        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "NoActiveProfile")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "ActiveProfile")?.withRenderingMode(.alwaysOriginal)
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
