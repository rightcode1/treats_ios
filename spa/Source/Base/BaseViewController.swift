import UIKit
import JGProgressHUD
import RxSwift
import RxGesture
import FirebaseAnalytics
import DKImagePickerController

class BaseViewController: UIViewController {
  
  // MARK: Properties
  
  lazy private(set) var className: String = {
    return type(of: self).description().components(separatedBy: ".").last ?? ""
  }()
  
  
  // MARK: Initializing
  
  deinit {
    log.verbose("DEINIT: \(self.className)")
  }
  
  // MARK: Rx
  
  var disposeBag = DisposeBag()
  
  @IBInspectable var localizedText: String = "" {
    didSet {
      if localizedText.count > 0 {
        #if TARGET_INTERFACE_BUILDER
        let bundle = Bundle(for: type(of: self))
        self.title = bundle.localizedString(forKey: self.localizedText, value:"", table: nil)
        #else
        self.title = NSLocalizedString(self.localizedText, comment:"");
        #endif
      }
    }
  }
  func compareDateComponents(lhs: DateComponents, rhs: DateComponents) -> Bool {
      if lhs.hour! < rhs.hour! {
        return false
      } else if lhs.hour! == rhs.hour! {
          return lhs.minute! >= rhs.minute!
      } else {
        return true
      }
  }
func showImagePicker(from viewController: UIViewController, maxSelectableCount: Int = 1, completion: @escaping ([UIImage]) -> Void) {
    let pickerController = DKImagePickerController()
    pickerController.maxSelectableCount = maxSelectableCount
    pickerController.didSelectAssets = { (assets: [DKAsset]) in
        var selectedImages = [UIImage]()
        let dispatchGroup = DispatchGroup()
        for asset in assets {
            dispatchGroup.enter()
            asset.fetchOriginalImage(completeBlock: { (image, info) in
                if let selectedImage = image {
                    selectedImages.append(selectedImage)
                }
                dispatchGroup.leave()
            })
        }
        dispatchGroup.notify(queue: .main) {
            completion(selectedImages)
        }
    }
    pickerController.didCancel = {
        completion([])
    }
    viewController.present(pickerController, animated: true, completion: nil)
}
  
  
  // MARK: View Lifecycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    log.warning("==== memory warnning ====")
  }
  
  @objc
  func keyboardWillAppear(_ animated: Bool) {
//    log.verbose("keyboard show!")
  }
  
  @objc
  func keyboardWillDisappear(_ animated: Bool) {
//    log.verbose("keyboard hide!")
  }
  
  // MARK: Layout Constraints
  
  private(set) var didSetupConstraints = false
  
  override func viewDidLoad() {
    self.view.setNeedsUpdateConstraints()
  }
  
  override func updateViewConstraints() {
    if !self.didSetupConstraints {
      self.setupConstraints()
      self.didSetupConstraints = true
    }
    super.updateViewConstraints()
  }
  
  func setupConstraints() {
    // Override point
  }

}
