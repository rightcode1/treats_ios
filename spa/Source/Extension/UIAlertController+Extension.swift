import Foundation
import UIKit
import LocalAuthentication

extension UIAlertController{
  static var defaultTitle:String{
    return "알림"
  }

  static func present(_ target: UIAlertController,animated: Bool, completion: (() -> Void)?) {
    if let rootVC = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController {
      presentFromController(target,controller: rootVC, animated: animated, completion: completion)
    }
  }

  static func presentFromController(_ target: UIAlertController,controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
    if let navVC = controller as? UINavigationController,
       let visibleVC = navVC.visibleViewController {
      presentFromController(target,controller: visibleVC, animated: animated, completion: completion)
    } else
    if let tabVC = controller as? UITabBarController,
       let selectedVC = tabVC.selectedViewController {
      presentFromController(target,controller: selectedVC, animated: animated, completion: completion)
    } else {
      controller.present(target, animated: animated, completion: completion);
    }
  }

  //    @available(iOS, deprecated)
  //    static func show(forReason reason: String?, successCallback: @escaping (()->Void), failureCallback: @escaping ((NSError)->Void)){
  //        LAContext.show(forReaon: reason, successCallback: successCallback, failureCallback: failureCallback)
  //    }

  static func show(_ context: UIViewController? = nil, title: String = defaultTitle, message: String, acceptCallback: ((UIAlertAction) -> Void)? = nil){
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "확인", style: .default, handler: acceptCallback)
    alert.addAction(action)

    if let context = context{
      context.present(alert, animated: true, completion: nil)
    }else{
      present(alert, animated: true, completion: nil)
    }
  }

  static func show(_ context: UIViewController? = nil, title: String = defaultTitle, message: String, acceptCallback: ((UIAlertAction) -> Void)? = nil
                   , denyCallback: ((UIAlertAction) -> Void)? = nil){
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let denyAction = UIAlertAction(title: "취소", style: .cancel, handler: denyCallback)
    alert.addAction(denyAction)
    let acceptAction = UIAlertAction(title: "확인", style: .default, handler: acceptCallback)
    alert.addAction(acceptAction)

    if let context = context{
      context.present(alert, animated: true, completion: nil)
    }else{
      present(alert, animated: true, completion: nil)
    }
  }

  static func showWithImage(_ context: UIViewController? = nil,
                            image: UIImage,
                            title: String = defaultTitle,
                            message: String,
                            acceptCallback: ((UIAlertAction) -> Void)? = nil,
                            denyCallback: ((UIAlertAction) -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

    let maxSize = CGSize(width: 100, height: 100)
    let imgSize = image.size

    var ratio: CGFloat!
    if imgSize.width > imgSize.height {
      ratio = maxSize.width / imgSize.width
    }else {
      ratio = maxSize.height / imgSize.height
    }

    let scaledSize = CGSize(width: imgSize.width * ratio, height: imgSize.height * ratio)

    var resizedImage = image.resize(to: scaledSize)!

    print("scaledSize: \(scaledSize)")

    let alertViewWidth: CGFloat = 270
    let alertViewPadding: CGFloat = 12
    let left = -alertViewWidth/2 + (scaledSize.width/2) + alertViewPadding
    print("left: \(left)")
    resizedImage = resizedImage.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: left, bottom: 0, right: 0))

    let imageAction = UIAlertAction(title: "", style: .default, handler: nil)
    imageAction.isEnabled = false

    imageAction.setValue(resizedImage.withRenderingMode(.alwaysOriginal), forKey: "image")
    alert.addAction(imageAction)

    let denyAction = UIAlertAction(title: "취소", style: .cancel, handler: denyCallback)
    alert.addAction(denyAction)
    let acceptAction = UIAlertAction(title: "확인", style: .default, handler: acceptCallback)
    alert.addAction(acceptAction)

    if let context = context {
      context.present(alert, animated: true, completion: nil)
    }else {
      present(alert, animated: true, completion: nil)
    }
  }

  static func showActionSheet(_ context: UIViewController? = nil,
                              title: String? = nil,
                              message: String? = nil,
                              positiveOptions: [String : ((UIAlertAction) -> Void)?]? = nil,
                              negativeOptions:  [String : ((UIAlertAction) -> Void)?]? = nil,
                              cancelCallback: ((UIAlertAction) -> Void)? = nil){

    let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: cancelCallback ?? { _ in
      alert.dismiss(animated: true, completion: nil)
    })
    positiveOptions?.forEach{ option in
      let action = UIAlertAction(title: option.key, style: .default, handler: option.value)
      alert.addAction(action)
    }
    negativeOptions?.forEach{ option in
      let action = UIAlertAction(title: option.key, style: .destructive, handler: option.value)
      alert.addAction(action)
    }
    alert.addAction(cancelAction)

    if let context = context{
      context.present(alert, animated: true, completion: nil)
    }else{
      present(alert, animated: true, completion: nil)
    }
  }
}
