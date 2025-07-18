import UIKit

extension UIWindow {
    func setRootViewController(_ viewController: UIViewController, animated: Bool = true) {
        guard animated, let snapshot = self.snapshotView(afterScreenUpdates: true) else {
            self.rootViewController = viewController
            self.makeKeyAndVisible()
            return
        }

        viewController.view.addSubview(snapshot)
        self.rootViewController = viewController
        self.makeKeyAndVisible()

        UIView.animate(withDuration: 0.3, animations: {
            snapshot.alpha = 0
        }, completion: { _ in
            snapshot.removeFromSuperview()
        })
    }
}
