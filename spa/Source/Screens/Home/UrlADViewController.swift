//
//  UrlADViewController.swift
//  spa
//
//  Created by 이동석 on 2022/11/30.
//

import UIKit
import WebKit

class UrlADViewController: BaseViewController {
  @IBOutlet weak var webView: WKWebView!
  @IBOutlet weak var titleLabel: UILabel!

  var advertisement: Advertisement?
  var detailStoreName: String?
  var detailUrl: URL?

  override func viewDidLoad() {
    super.viewDidLoad()
    if advertisement != nil{
      self.titleLabel.text = advertisement?.name
      if let url = URL(string: advertisement?.url ?? "") {
        webView.load(URLRequest(url: url))
      }
    }else{
      self.titleLabel.text = detailStoreName
      webView.load(URLRequest(url: detailUrl!))
    }
  }
}
