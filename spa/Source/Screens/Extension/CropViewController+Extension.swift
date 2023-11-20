import Foundation
import UIKit
import CropViewController

extension CropViewController{
  @discardableResult
  class func show(_ viewController: UIViewController & CropViewControllerDelegate, image: UIImage, identifier: String? = nil) -> CropViewController{
    let cropViewController = CropViewController(image: image)
    cropViewController.aspectRatioPreset = .presetSquare
    cropViewController.aspectRatioLockEnabled = true
    cropViewController.aspectRatioPickerButtonHidden = true
    cropViewController.resetAspectRatioEnabled = false
    cropViewController.delegate = viewController
    cropViewController.accessibilityValue = identifier
    cropViewController.modalPresentationStyle = .fullScreen

    viewController.present(cropViewController, animated: false, completion: nil)
    return cropViewController
  }
}
