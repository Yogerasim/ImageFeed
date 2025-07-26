import UIKit

// MARK: - MainTabBarController

final class MainTabBarController: UITabBarController {

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureViewControllers()
    }


    // MARK: - Setup View Controllers

    private func configureViewControllers() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: .main)

        let imagesListViewController = mainStoryboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        let profileViewController = ProfileViewController()

        imagesListViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: TabBarIcons.inactiveScrollImageName)?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: TabBarIcons.activeScrollImageName)?.withRenderingMode(.alwaysOriginal)
        )
        imagesListViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)

        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: TabBarIcons.inactiveProfileImageName)?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: TabBarIcons.activeProfileImageName)?.withRenderingMode(.alwaysOriginal)
        )
        profileViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)

        viewControllers = [imagesListViewController, profileViewController]
    }

    // MARK: - Tab Bar Icons

    private enum TabBarIcons {
        static let inactiveScrollImageName = "NoActiveScroll"
        static let activeScrollImageName = "ActiveScroll"
        static let inactiveProfileImageName = "NoActiveProfile"
        static let activeProfileImageName = "ActiveProfile"
    }
}
