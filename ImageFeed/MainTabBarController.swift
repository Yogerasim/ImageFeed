import UIKit

final class MainTabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()

        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        let profileViewController = ProfileViewController()

        imagesListViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: TabBarIcons.inactiveScroll)?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: TabBarIcons.activeScroll)?.withRenderingMode(.alwaysOriginal)
        )

        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: TabBarIcons.inactiveProfile)?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: TabBarIcons.activeProfile)?.withRenderingMode(.alwaysOriginal)
        )

        viewControllers = [imagesListViewController, profileViewController]
    }

    private enum TabBarIcons {
        static let inactiveScroll = "NoActiveScroll"
        static let activeScroll = "ActiveScroll"
        static let inactiveProfile = "NoActiveProfile"
        static let activeProfile = "ActiveProfile"
    }
}
