//
//  UpdateViewController.swift
//  Skin52
//
//  Created by hoonKim on 2020/09/29.
//  Copyright © 2020 hoonKim. All rights reserved.
//

import UIKit

class UpdateViewController: UIViewController {
  
  //  var version: String? {
  //      guard let dictionary = Bundle.main.infoDictionary,
  //          let version = dictionary["CFBundleShortVersionString"] as? String,
  //          let build = dictionary["CFBundleVersion"] as? String else {return nil}
  //
  //      let versionAndBuild: String = "vserion: \(version), build: \(build)"
  //      return versionAndBuild
  //  }
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  @IBAction func tapUpdate(_ sender: UIButton) {
    if let url = URL(string: "https://apps.apple.com/kr/app/%ED%8F%AC%EC%95%84%EB%B8%8C/id1670037715"), UIApplication.shared.canOpenURL(url) {
      if #available(iOS 10.0, *) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      } else {
        UIApplication.shared.openURL(url)
      }
    }
  }
  
  
}
