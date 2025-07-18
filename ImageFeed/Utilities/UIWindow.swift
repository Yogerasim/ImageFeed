import UIKit

extension UIWindow {
    func setRootViewController(_ viewController: UIViewController, animated: Bool = true) {
        guard animated, let snapshot = snapshotView(afterScreenUpdates: true) else {
            rootViewController = viewController
            makeKeyAndVisible()
            return
        }

        viewController.view.addSubview(snapshot)
        rootViewController = viewController
        makeKeyAndVisible()

        UIView.animate(withDuration: 0.3, animations: {
            snapshot.alpha = 0
        }, completion: { _ in
            snapshot.removeFromSuperview()
        })
    }
}
