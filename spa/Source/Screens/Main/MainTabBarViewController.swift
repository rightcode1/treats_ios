//
//  MainTabBarViewController.swift
//  ginger9
//
//  Created by jason on 2021/04/05.
//

import UIKit
import BSImagePicker
import Photos

class MainTabBarViewController: UITabBarController, UITabBarControllerDelegate {

  override func viewDidLoad() {
    super.viewDidLoad()

    viewControllers = [
      UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController()!,
      UIStoryboard(name: "Store", bundle: nil).instantiateInitialViewController()!,
      UIStoryboard(name: "Magazine", bundle: nil).instantiateInitialViewController()!,
      UIStoryboard(name: "Review", bundle: nil).instantiateInitialViewController()!,
      UIStoryboard(name: "Mypage", bundle: nil).instantiateInitialViewController()!
    ]

    if #available(iOS 15.0, *) {
      let appearance = UITabBarAppearance()
      appearance.configureWithOpaqueBackground()
      appearance.backgroundColor = .white
      tabBar.standardAppearance = appearance
      tabBar.scrollEdgeAppearance = tabBar.standardAppearance
    } else {

    }
//
    tabBar.tintColor = .black
//    delegate = self
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
 
  }
}
