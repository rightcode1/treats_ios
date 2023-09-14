import UIKit
import Gifu
import CoreLocation
import RxViewController
import FirebaseMessaging

class SplashViewController: BaseViewController {
  @IBOutlet var splashImageView: GIFImageView!
  let manager = CLLocationManager()

  var advertisement: Advertisement?
  
  var versionNumber: String? {
    guard let dictionary = Bundle.main.infoDictionary,
          let build = dictionary["CFBundleVersion"] as? String else {return nil}
    return build
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    self.splashImageView.animate(withGIFNamed: "spaIntro")
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
    APIService.shared.homeAPI.rx.request(.visitCount)
      .subscribe()
      .disposed(by: self.disposeBag)
    if DataHelperTool.userId != nil {
      APIService.shared.userAPI.rx.request(.getUserInfo)
        .filterSuccessfulStatusCodes()
        .map(User.self)
        .subscribe(onSuccess: { response in
          if let setting = response.setting {
            DataHelper<Bool>.set(setting.agreeMarketingPush, forKey: .agreeMarketingPush)
            DataHelper<Bool>.set(setting.agreeChatPush, forKey: .agreeChatPush)
          }
        })
        .disposed(by: self.disposeBag)
    }

      self.manager.delegate = self

      switch self.manager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      // 현재 위치 가져오기
        self.manager.startUpdatingLocation()
      break
    case .notDetermined:
      // 권한 요청
        self.manager.requestWhenInUseAuthorization()
    case .denied, .restricted:
      if LocationManager.shared.currentLocation == nil {
        LocationManager.shared.currentLocation = CLLocationCoordinate2D(latitude: 37.5331, longitude: 127.0068)
        LocationManager.shared.getCrrentLocationAddress {
          self.checkApp()
        }
      }
      // 앱 설정화면 안내
//      self.callOkActionMSGDialog(message: "원할한 앱 사용을 위해 위치정보 권한이 필요합니다") {
//        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
//      }
    @unknown default:
      break
    }
    }
  }
  func checkApp(){
      APIService.shared.authAPI.rx.request(.checkAppVersion)
        .filterSuccessfulStatusCodes()
        .map(CheckAppVersionResponse.self)
        .subscribe(onSuccess: { response in
          print(response)
          let version: Int = Int(self.versionNumber!) ?? 0
          if version < response.ios {
            let vc = UIStoryboard.init(name: "Onboard", bundle: nil).instantiateViewController(withIdentifier: "UpdateViewController")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
          } else {
            self.registToken()
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! MainTabBarViewController
            self.appDelegate.window?.rootViewController = vc
          }
        }, onFailure: { error in
        })
    .disposed(by: disposeBag)
  }
  func registToken() {
    let param = NotificationRequest (
      notificationToken: DataHelper<String>.value(forKey: .pushToken) ?? ""
    )
    
    APIService.shared.authAPI.rx.request(.sendNotificationToken(param: param))
      .filterSuccessfulStatusCodes()
      .map(Notification.self)
      .subscribe(onSuccess: { response in
      }, onFailure: { error in
      })
  .disposed(by: disposeBag)
  }
}

extension SplashViewController: CLLocationManagerDelegate {
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    switch manager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      // 현재 위치 가져오기
      manager.startUpdatingLocation()
      break
    case .notDetermined:
      // 권한 요청
      manager.requestWhenInUseAuthorization()
    case .denied, .restricted:
      LocationManager.shared.currentLocation = CLLocationCoordinate2D(latitude: 37.5331, longitude: 127.0068)
      LocationManager.shared.getCrrentLocationAddress {
        self.checkApp()
      }
      // 앱 설정화면 안내
//      self.callOkActionMSGDialog(message: "원할한 앱 사용을 위해 위치정보 권한이 필요합니다") {
//        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
//      }
    @unknown default:
      break
    }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    log.error(error)
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    manager.stopUpdatingLocation()
    if LocationManager.shared.currentLocation == nil {
      LocationManager.shared.currentLocation = locations.first?.coordinate
      LocationManager.shared.getCrrentLocationAddress {
        self.checkApp()
      }
    }
  }
}
