//
//  AppDelegate.swift
//  spa
//
//  Created by 이동석 on 2022/10/19.
//

import UIKit
import IQKeyboardManagerSwift
import KakaoSDKCommon
import RxKakaoSDKCommon
import KakaoSDKAuth
import RxKakaoSDKAuth
import KakaoSDKUser
import RxKakaoSDKUser
import KakaoSDKShare
import Firebase
import RxSwift
import iamport_ios
import NaverThirdPartyLogin
import GoogleSignIn
import SocketIO
import KakaoSDKShare
import KakaoSDKTemplate
import SafariServices


@main
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {
  

  var window: UIWindow?
  let disposeBag = DisposeBag()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    let tabBarController = window?.rootViewController as? UITabBarController
    tabBarController?.delegate = self

    KakaoSDK.initSDK(appKey: "b02309dd49498b640a2c1687aaa65b69")
    GIDSignIn.sharedInstance().clientID = "1047439069474-aukmvkm5d1523itjt9pephk90qtj1lmo.apps.googleusercontent.com"
    let instance = NaverThirdPartyLoginConnection.getSharedInstance()
     
    // 네이버 앱으로 인증하는 방식을 활성화z
    instance?.isNaverAppOauthEnable = false
    // SafariViewController에서 인증하는 방식을 활성화
    instance?.isInAppOauthEnable = true
    instance?.isOnlyPortraitSupportedInIphone()
    
    instance?.serviceUrlScheme = "navertreatlogin"
    // 애플리케이션 등록 후 발급받은 클라이언트 아이디
    instance?.consumerKey = "bm287cdFhTxZ6rH71BjI"
    // 애플리케이션 등록 후 발급받은 클라이언트 시크릿
    instance?.consumerSecret = "PQMTZQxcEn"
    // 애플리케이션 이름
    instance?.appName = "트리니티스파"

    // MARK: - IQKeyboardManager
    IQKeyboardManager.shared.enable = true
    IQKeyboardManager.shared.enableAutoToolbar = true
    IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "완료"
    IQKeyboardManager.shared.toolbarBarTintColor = UIColor(hex: "#eff0f1")
    
    // MARK: - Firebase
    let filebaseResource = Bundle.main.object(forInfoDictionaryKey: "FIREBASE_RESOURCE") as! String
    let filePath = Bundle.main.path(forResource: filebaseResource, ofType: "plist")
    guard let fileopts = FirebaseOptions.init(contentsOfFile: filePath!) else {
      assert(false, "Couldn't load config file")
      return true
    }
    FirebaseApp.configure(options: fileopts)

    // MARK: - Notification
    UNUserNotificationCenter.current().delegate = self
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
    application.registerForRemoteNotifications()

    Messaging.messaging().delegate = self

    return true
  }

  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if url.scheme == "treatspa" {
      print("=======url:\(url)===========")
      print("=======scheme:\(url.scheme)===========")
      print("=======host:\(url.host)===========")
      print("=======param:\(url.params()?.first)===========")
      print("=======id:\(url.params()?.first?.value ?? 0)===========")
      switch(url.host){
      case "goReservation","goCancelReservation":
        let id = url.params()?.urlQueryItems?.first?.value
          if let tabBarViewController = window?.rootViewController as? MainTabBarViewController {
            if let nav = tabBarViewController.viewControllers?[tabBarViewController.selectedIndex] as? UINavigationController {
              let vc = UIStoryboard(name: "Mypage", bundle: nil).instantiateViewController(withIdentifier: "orderDetail") as! OrderDetailViewController
              vc.id = Int(id ?? "0")
              nav.pushViewController(vc, animated: true)
            }
          }
        break
      case "goRegistReview":
        let id = url.params()?.urlQueryItems?.first?.value
          if let tabBarViewController = window?.rootViewController as? MainTabBarViewController {
            if let nav = tabBarViewController.viewControllers?[tabBarViewController.selectedIndex] as? UINavigationController {
              let vc = UIStoryboard(name: "Mypage", bundle: nil).instantiateViewController(withIdentifier: "editReview") as! EditReviewViewController
              vc.id = Int(id ?? "0")!
              nav.pushViewController(vc, animated: true)
            }
          }
        break
      case "shareReservation":
        let id = url.params()?.urlQueryItems?.first?.value
          if let tabBarViewController = window?.rootViewController as? MainTabBarViewController {
            if let nav = tabBarViewController.viewControllers?[tabBarViewController.selectedIndex] as? UINavigationController {
              let vc = UIStoryboard(name: "Mypage", bundle: nil).instantiateViewController(withIdentifier: "orderDetail") as! OrderDetailViewController
              vc.id = Int(id ?? "0")
              vc.diffShare = true
              nav.pushViewController(vc, animated: true)
            }
          }
        break
      default:
        break
      }
      return true
    }else{
      var result = false
      Iamport.shared.receivedURL(url)
      print(result)
      if AuthApi.isKakaoTalkLoginUrl(url) {
          result = AuthController.handleOpenUrl(url: url)
      }
      if !result {
        result = ((NaverThirdPartyLoginConnection.getSharedInstance()?.application(app, open: url, options: options)) != nil)
      }
      
      if !result {
        result = GIDSignIn.sharedInstance().handle(url)
      }
      return result
    }
  }
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    log.info(userInfo)
  }
  func applicationDidBecomeActive(_ application: UIApplication) {
    if DataHelperTool.accessToken != nil && !SocketIOManager.sharedInstance.isConnected{
          SocketIOManager.sharedInstance.connection()
      }
  }
  func applicationDidEnterBackground(_ application: UIApplication) {
      if SocketIOManager.sharedInstance.isConnected{
          SocketIOManager.sharedInstance.disConnection()
      }
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.sound, .badge, .banner, .list]) //.list
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    log.info(userInfo)
    if let advertisementId = Int((userInfo["advertisementId"] as? String) ?? "") {
      APIService.shared.homeAPI.rx.request(.getAdvertisement(id: advertisementId))
        .filterSuccessfulStatusCodes()
        .map(Advertisement.self)
        .subscribe(onSuccess: { response in
          self.goAdvertisement(response)
        }, onFailure: { error in
          log.error(error)
        })
        .disposed(by: disposeBag)
//      if let tabBarViewController = window?.rootViewController as? MainTabBarViewController {
//        if let nav = tabBarViewController.viewControllers?[tabBarViewController.selectedIndex] as? UINavigationController {
//          let vc = UIStoryboard(name: "Store", bundle: nil).instantiateViewController(withIdentifier: "storeDetail") as! StoreDetailViewController
//          vc.storeId = storeId
//          nav.pushViewController(vc, animated: true)
//        }
//      } else {
//        DataHelper.set(storeId, forKey: .pushStoreId)
//      }
    } else if let storeId = Int((userInfo["storeId"] as? String) ?? "") {
      goStore(id: storeId)
    } else {
      log.info("goHome")
    }

    completionHandler()
  }

  func goAdvertisement(_ advertisement: Advertisement) {
    if let tabBarViewController = window?.rootViewController as? MainTabBarViewController {
      if let nav = tabBarViewController.viewControllers?[tabBarViewController.selectedIndex] as? UINavigationController {
        switch advertisement.division {
        case .url:
          if let url = URL(string: advertisement.url ?? "") {
            UIApplication.shared.open(url)
          }
        case .image:
          let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "imageAD") as! ImageADViewController
          vc.advertisement = advertisement
          nav.pushViewController(vc, animated: true)
        case .store:
          let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "storeAD") as! StoreADViewController
          vc.advertisement = advertisement
          nav.pushViewController(vc, animated: true)
        }
      }
    } else {
      let vc = window?.rootViewController as? SplashViewController
      vc?.advertisement = advertisement
    }
  }

  func goStore(id: Int) {
    if let tabBarViewController = window?.rootViewController as? MainTabBarViewController {
      if let nav = tabBarViewController.viewControllers?[tabBarViewController.selectedIndex] as? UINavigationController {
      let vc = UIStoryboard(name: "Store", bundle: nil).instantiateViewController(withIdentifier: "storeDetail") as! StoreDetailViewController
        vc.storeId = id
        nav.pushViewController(vc, animated: true)
      }
    } else {
      DataHelper.set(id, forKey: .pushStoreId)
    }
  }
  


}

extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    if let fcmToken = fcmToken {
      log.info("!!!!!!!!!!!\(fcmToken)")
      
      DataHelper.set(fcmToken, forKey: .pushToken)
      if DataHelperTool.agreeMarketingPush {
        Messaging.messaging().subscribe(toTopic: "marketing")
      } else {
        Messaging.messaging().unsubscribe(fromTopic: "marketing")
      }
    }
  }
}
