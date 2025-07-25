import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!

    var imageURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.delegate = self

        loadImage()
    }

    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let shareController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(shareController, animated: true, completion: nil)
    }
}

// MARK: - Image Loading

private extension SingleImageViewController {
    func loadImage() {
        guard let url = imageURL else {
            print("❌ URL не задан")
            return
        }

        print("🔗 Загружаем полноразмерное изображение:", url)

        UIBlockingProgressHUD.show()

        imageView.kf.setImage(with: url) { [weak self] result in
            guard let self else { return }

            UIBlockingProgressHUD.dismiss()

            switch result {
            case .success(let value):
                print("✅ Изображение успешно загружено: \(value.source.url?.absoluteString ?? "—")")
                DispatchQueue.main.async {
                    self.imageView.frame.size = value.image.size
                    self.rescaleAndCenterImageInScrollView(image: value.image)
                }

            case .failure(let error):
                print("❌ Ошибка загрузки изображения:", error.localizedDescription)
                self.showError()
            }
        }
    }

    func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage()
        })

        present(alert, animated: true)
    }
}

// MARK: - Image Scaling & Centering

private extension SingleImageViewController {
    func centerImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size

        let verticalInset = max(0, (scrollViewSize.height - imageViewSize.height) / 2)
        let horizontalInset = max(0, (scrollViewSize.width - imageViewSize.width) / 2)

        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }

    func rescaleAndCenterImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()

        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size

        guard imageSize.width != 0, imageSize.height != 0 else {
            assertionFailure("Image has zero width or height.")
            return
        }

        print("📐 Расчёт масштаба: scrollView: \(visibleRectSize), image: \(imageSize)")

        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))

        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()

        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2

        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
        centerImage()
    }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
