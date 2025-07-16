import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var currentWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first
    }

    static func show() {
        DispatchQueue.main.async {
            currentWindow?.isUserInteractionEnabled = false
            ProgressHUD.animate()
        }
    }

    static func dismiss() {
        DispatchQueue.main.async {
            currentWindow?.isUserInteractionEnabled = true
            ProgressHUD.dismiss()
        }
    }
}
