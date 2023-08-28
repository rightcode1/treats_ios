//
//  PaymentViewController.swift
//  spa
//
//  Created by 이동석 on 2022/11/18.
//

import UIKit
import WebKit

class PaymentViewController: BaseViewController {
  @IBOutlet weak var containerView: UIView!

  var orderSheet: OrderSheet?
  var amount = 0
  var webView: WKWebView!

  var html: String!

  override func loadView() {
    super.loadView()


  }

  override func viewDidLoad() {
    super.viewDidLoad()

    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.webView = WKWebView(frame: self.containerView.frame, configuration: self.initConfig())

      self.webView.navigationDelegate = self
      self.webView.uiDelegate = self
      self.view.addSubview(self.webView)

      self.webView.loadHTMLString(self.html, baseURL: URL(string: "https://api.spa-dev.com"))
    }
  }

  func paymentSuccess(orderId: Int) {

  }

  func paymentFail() {
    let alertController = UIAlertController(title: "결제가 취소되었습니다", message: "다시 시도해 주세요", preferredStyle: UIAlertController.Style.alert)

    let okAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { (_: UIAlertAction) in
      self.dismiss(animated: true, completion: nil)
    }
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
  }
}

extension PaymentViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    debugPrint("didFinish \(webView.url!.debugDescription)")
    if let urlComponents = URLComponents(url: webView.url!, resolvingAgainstBaseURL: true) {
      log.info(urlComponents)
      if "\(urlComponents.scheme ?? "")://\(urlComponents.host ?? "")" == Environment.baseUrl {
        if urlComponents.path == "/payments/complete" {
          let vc = storyboard?.instantiateViewController(withIdentifier: "paymentComplete") as! PaymentCompleteViewController
          vc.orderSheet = self.orderSheet
          vc.amount = self.amount
          navigationController?.pushViewController(vc, animated: true)
        }
      }
    }
  }

  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    debugPrint("didFail \(webView.url!.debugDescription)")
  }

  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
    guard let url = navigationAction.request.url else {
      decisionHandler(.allow)
      return
    }

    let application = UIApplication.shared

    let urlString = url.absoluteString.lowercased()
    let bAppStoreURL = urlString.contains("phobos.apple.com")
    let bAppStoreURL2 = urlString.contains("itunes.apple.com")

    if bAppStoreURL || bAppStoreURL2 {
      application.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
      decisionHandler(.cancel)
    }
    else if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
      decisionHandler(.allow)
    }
    else if urlString.hasPrefix("ispmobile://") {
      if application.canOpenURL(url) {
        application.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        decisionHandler(.cancel)
      }
      else {
        let alert = UIAlertController(title: "",
                                      message: "모바일 ISP가 설치되어 있지 않아\nApp Store로 이동합니다.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: { _ in
          let str = "https://itunes.apple.com/app/kakaotalk-messenger/id362057947?mt=8"
          application.open(URL(string: str)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
          alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
        decisionHandler(.cancel)
      }
    }
    else if urlString.hasPrefix("kakaotalk://") {
      if application.canOpenURL(url) {
        application.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        decisionHandler(.cancel)
      }
      else {
        let alert = UIAlertController(title: "",
                                      message: "카카오 앱이 설치되어 있지 않아\nApp Store로 이동합니다.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: { _ in
          let str = "https://itunes.apple.com/app/mobail-gyeolje-isp/id369125087?mt=8"
          application.open(URL(string: str)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
          alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
        decisionHandler(.cancel)
      }
    }
    else if application.canOpenURL(url) {
      application.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
      decisionHandler(.cancel)
    }
    else {
      decisionHandler(.allow)
    }
  }
}

extension PaymentViewController: WKScriptMessageHandler {
  func initConfig() -> WKWebViewConfiguration {
    let contentController = WKUserContentController()
    contentController.add(self, name: "callbackHandler")
    let config = WKWebViewConfiguration()
    config.userContentController = contentController

    return config
  }

  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    if message.name == "callbackHandler" {
      if let object = message.body as? [String: Any] {
        debugPrint(object.debugDescription)

        if let command = object["command"] as? String, command == "paymentSuccess", let orderId = object["orderId"] as? Int {
          paymentSuccess(orderId: orderId)
        }
        else {
          paymentFail()
        }
      }
    }
  }
}

extension PaymentViewController: WKUIDelegate {
  func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Swift.Void) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .cancel) { _ in
      completionHandler()
      alert.dismiss(animated: true, completion: nil)
    })
    present(alert, animated: true, completion: nil)
  }

  func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .cancel) { _ in
      completionHandler(true)
      alert.dismiss(animated: true, completion: nil)
    })
    present(alert, animated: true, completion: nil)
  }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
  return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value) })
}
