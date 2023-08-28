import Foundation
import UIKit
import JGProgressHUD

extension UIViewController {
  var progressHUD: JGProgressHUD {
    let hud = JGProgressHUD(style: .dark)
    return hud
  }
  
  func showHUD(){
    DispatchQueue.main.async {
      self.progressHUD.show(in: self.view, animated: true)
      self.view.isUserInteractionEnabled = false
    }
  }
  
  func dismissHUD(){
    DispatchQueue.main.async {
      JGProgressHUD.allProgressHUDs(in: self.view).forEach{ hud in
        hud.dismiss(animated: true)
      }
      self.view.isUserInteractionEnabled = true
    }
  }
  
  var appDelegate:AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
  }
  
  func swipeDownToDismiss(target: UIView? = nil, action: Selector? = #selector(dismissViewController(_:))){
    let recognizer = UISwipeGestureRecognizer(target: self, action: action)
    recognizer.direction = .down
    
    var targetView = target
    if targetView == nil{
      targetView = self.view
    }
    targetView?.addGestureRecognizer(recognizer)
  }
  
  @objc func dismissViewController(_ sender: Any){
    self.dismiss(animated: true, completion: nil)
  }
  
  func hideKeyboardWhenTappedAround(target: UIView? = nil, action: Selector? = #selector(dismissKeyboard)) {
    let recognizer = UITapGestureRecognizer(target: self, action: action)
    recognizer.cancelsTouchesInView = false
    
    var targetView = target
    if targetView == nil{
      targetView = self.view
    }
    targetView?.addGestureRecognizer(recognizer)
  }
  
  @objc func dismissKeyboard(force: Bool = false) {
    self.view.endEditing(force)
  }

  func callMSGDialog(message: String) {
    DispatchQueue.main.async {
      self.view.endEditing(true)
      let vc = UIAlertController(title: message, message: nil, preferredStyle: .alert)
      let confirmAction = UIAlertAction(title: "확인", style: .default)
      vc.addAction(confirmAction)
      self.present(vc, animated: true)
    }
  }
  func showToast(message : String, font: UIFont? = UIFont.systemFont(ofSize: 14)) {
    let toastLabel = UILabel(frame: CGRect(x: (self.view.frame.size.width/2) - 125, y: self.view.frame.size.height-100, width: 250, height: 38))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 12;
    toastLabel.clipsToBounds = true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 2.0, delay: 1.3, options: .curveEaseOut, animations: {
      toastLabel.alpha = 0.0
    },
    completion: { (isCompleted) in
      toastLabel.removeFromSuperview()
    })
  }
  

  func callOkActionMSGDialog(message: String, buttonTitle: String = "확인", okAction: @escaping () -> Void) {
    DispatchQueue.main.async {
      self.view.endEditing(true)
      let vc = UIAlertController(title: message, message: nil, preferredStyle: .alert)
      let confirmAction = UIAlertAction(title: "확인", style: .default) { action in
        okAction()
      }
      vc.addAction(confirmAction)
      self.present(vc, animated: true)
    }
  }

  func callOkCancelMSGDialog(message: String, okAction: @escaping () -> Void) {
    view.endEditing(true)
    DispatchQueue.main.async {
      self.view.endEditing(true)
      let vc = UIAlertController(title: message, message: nil, preferredStyle: .alert)
      let confirmAction = UIAlertAction(title: "확인", style: .default) { action in
        okAction()
      }
      vc.addAction(confirmAction)

      let cancelAction = UIAlertAction(title: "취소", style: .cancel) { action in }
      vc.addAction(cancelAction)
      self.present(vc, animated: true)
    }
  }

  func showLoginViewController() {
    let vc = UIStoryboard(name: "Onboard", bundle: nil).instantiateViewController(withIdentifier: "onboardNav")
    self.present(vc, animated: true)
  }

  // MARK: - IBAction
  
  @IBAction func backPress(){
    if let navigationController = navigationController{
      if let rootViewController = navigationController.viewControllers.first, rootViewController.isEqual(self){
        dismiss(animated: true, completion: nil)
      }else{
        navigationController.popViewController(animated: true)
      }
    }else{
      dismiss(animated: true, completion: nil)
    }
  }
  
  @IBAction func backThree() {
    let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
    self.navigationController!.popToViewController(viewControllers[viewControllers.count - 4], animated: true)
  }

  @IBAction func dismissPress(){
    dismiss(animated: true, completion: nil)
  }

  @IBAction func dismissWithoutAnimation(){
    dismiss(animated: false, completion: nil)
  }
}
