//
//  UrlCommonViewController.swift
//  Treat
//
//  Created by 이남기 on 2023/09/07.
//

import Foundation
import UIKit
import WebKit

class UrlCommonViewController: BaseViewController , WKNavigationDelegate{
  @IBOutlet weak var webView: WKWebView!
  @IBOutlet weak var titleLabel: UILabel!

  var titleName: String?
  var url: URL?

  override func viewDidLoad() {
    super.viewDidLoad()
    showHUD()
    self.titleLabel.text = titleName
    webView.navigationDelegate = self
    webView.load(URLRequest(url: url!))
  }
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    dismissHUD()
  }
}
