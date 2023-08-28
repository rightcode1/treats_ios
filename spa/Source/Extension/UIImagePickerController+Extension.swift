import Foundation
import UIKit

extension UIImagePickerController{
  class func show(_ viewController: (UIImagePickerControllerDelegate & UINavigationControllerDelegate & UIViewController),
                  withIdentifier identifier: String? = nil,
                  cameraDevice: UIImagePickerController.CameraDevice = .rear,
                  disableCamera: Bool = false,
                  cancelCallback: ((UIAlertAction) -> Void)? = nil){
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = viewController
    imagePicker.accessibilityValue = identifier

    var positiveOptions: [String : ((UIAlertAction) -> Void)?] = [:]

    if isSourceTypeAvailable(.camera) && !disableCamera{
      positiveOptions = [
        "카메라": { _ in//"general_camera".localized: { _ in
          self.showCamera(viewController, withIdentifier: identifier, cameraDevice: cameraDevice)
        },
        "갤러리": { _ in//"general_gallery".localized: { _ in
          self.showGallery(viewController, withIdentifier: identifier)
        }
      ]
    }else{
      positiveOptions = [
        "갤러리": { _ in//"general_gallery".localized: { _ in
          self.showGallery(viewController, withIdentifier: identifier)
        }
      ]
    }

    UIAlertController.showActionSheet(
      viewController,
      positiveOptions: positiveOptions,
      cancelCallback: cancelCallback
    )
  }

  class func showCamera(_ viewController: (UIImagePickerControllerDelegate & UINavigationControllerDelegate & UIViewController),
                        withIdentifier identifier: String? = nil,
                        cameraDevice: UIImagePickerController.CameraDevice = .rear){
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = viewController
    imagePicker.accessibilityValue = identifier
    imagePicker.allowsEditing = false
    imagePicker.sourceType = .camera
    imagePicker.cameraCaptureMode = .photo
    imagePicker.modalPresentationStyle = .overCurrentContext
    imagePicker.cameraDevice = cameraDevice
    
    viewController.present(imagePicker, animated : true, completion : nil)
  }

  class func showGallery(_ viewController: (UIImagePickerControllerDelegate & UINavigationControllerDelegate & UIViewController),
                         withIdentifier identifier: String? = nil){
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = viewController
    imagePicker.accessibilityValue = identifier
    imagePicker.allowsEditing = false
    imagePicker.sourceType = .photoLibrary
    viewController.present(imagePicker, animated : true, completion : nil)
  }
}
