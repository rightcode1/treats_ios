//
//  LoginViewController.swift
//  myrrors
//
//  Created by 이동석 on 2022/09/19.
//

import UIKit
import KakaoSDKUser
import AuthenticationServices
import GoogleSignIn
import NaverThirdPartyLogin
import Alamofire


class LoginViewController: BaseViewController {
  @IBOutlet weak var loginButton: UIView!
  @IBOutlet weak var registerButton: UILabel!

  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!

  @IBOutlet weak var findEmailButton: UILabel!
  @IBOutlet weak var findPasswordButton: UILabel!

  @IBOutlet var appleLoginButton: UIImageView!
  @IBOutlet var kakaoLoginButton: UIImageView!
  @IBOutlet var naverLoginButton: UIImageView!
  @IBOutlet var googleLoginButton: UIImageView!
  var selectedBrandIdList = [Int]()
  let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()

  override func viewDidLoad() {
    super.viewDidLoad()
    checkApp()
    GIDSignIn.sharedInstance().delegate = self
    GIDSignIn.sharedInstance().presentingViewController = self
    loginInstance?.delegate = self
    bindInput()

    if !selectedBrandIdList.isEmpty {
      let vc = self.storyboard?.instantiateViewController(withIdentifier: "register") as! RegisterViewController
      vc.selectedBrandIdList = selectedBrandIdList
      self.navigationController?.pushViewController(vc, animated: false)
    }
  }
  override func viewWillAppear(_ animated: Bool) {
    loginInstance?.requestDeleteToken()
  }

  func bindInput() {
    loginButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.login()
      })
      .disposed(by: disposeBag)

    registerButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        let vc = UIStoryboard(name: "Onboard", bundle: nil).instantiateViewController(withIdentifier: "register") as! RegisterViewController
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)

    findEmailButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "findEmail") as! FindEmailViewController
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
    
    findPasswordButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "findPassword") as! FindPasswordViewController
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)

    appleLoginButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.apple()
      })
      .disposed(by: disposeBag)
    
    kakaoLoginButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.kakao()
      })
      .disposed(by: disposeBag)
    
    naverLoginButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.naver()
      })
      .disposed(by: disposeBag)
    
    googleLoginButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.google()
      })
      .disposed(by: disposeBag)
  }
  func checkApp(){
      APIService.shared.authAPI.rx.request(.checkAppVersion)
        .filterSuccessfulStatusCodes()
        .map(CheckAppVersionResponse.self)
        .subscribe(onSuccess: { response in
          self.appleLoginButton.isHidden = response.isHidden
          self.kakaoLoginButton.isHidden = response.isHidden
          self.naverLoginButton.isHidden = response.isHidden
          self.googleLoginButton.isHidden = response.isHidden
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
  func login() {
    if !emailTextField.text!.validateEmail() {
      callMSGDialog(message: "정확한 이메일을 입력해주세요")
      return
    }
    showHUD()
    APIService.shared.authAPI.rx.request(.login(email: emailTextField.text!, password: passwordTextField.text!))
      .filterSuccessfulStatusCodes()
      .map(AuthResponse.self)
      .subscribe(onSuccess: { response in
        self.dismissHUD()
        DataHelper<Int>.set(response.user.id, forKey: .userId)
        DataHelper<String>.set(response.token, forKey: .accessToken)
        self.registToken()
        let socketManager = SocketIOManager.sharedInstance
        socketManager.connection()
        socketManager.getRoomList { _ in
        }
        self.dismiss(animated: true)
//        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
//        self.appDelegate.window?.rootViewController = vc
      }, onFailure: { error in
        self.dismissHUD()
        self.callMSGDialog(message: "이메일 혹은 비밀번호를 확인해주세요")
      })
      .disposed(by: disposeBag)
  }
  func snsLogin(type: SocialType,id: String) {
    showHUD()
    print("snsLoginId: \(id)")
    let registerRequest = SocialLoginRequest(type: type,loginId: id)
    APIService.shared.authAPI.rx.request(.socialLogin(param: registerRequest))
      .filterSuccessfulStatusCodes()
      .map(AuthResponse.self)
      .subscribe(onSuccess: { response in
        self.dismissHUD()
        DataHelper<Int>.set(response.user.id, forKey: .userId)
        DataHelper<String>.set(response.token, forKey: .accessToken)
        let socketManager = SocketIOManager.sharedInstance
        socketManager.connection()
        socketManager.getRoomList { _ in
        }
        self.registToken()
        self.dismiss(animated: true)
      }, onFailure: { error in
        self.dismissHUD()
        print(error.moyaError?.response?.statusCode)
        if error.moyaError?.response?.statusCode == 203{
          let vc = self.storyboard?.instantiateViewController(withIdentifier: "snsregister") as! SnsJoingViewController
          vc.registRequest = registerRequest
          self.navigationController?.pushViewController(vc, animated: true)
        }
      })
      .disposed(by: disposeBag)
  }
  func naver(){
    loginInstance?.requestThirdPartyLogin()
  }
  func google(){
    GIDSignIn.sharedInstance().signIn()
  }
  func apple() {
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
  }
  func naverLoginPaser() {
            guard let accessToken = loginInstance?.isValidAccessTokenExpireTimeNow() else { return }
            
            if !accessToken {
              return
            }
            
            guard let tokenType = loginInstance?.tokenType else { return }
            guard let accessToken = loginInstance?.accessToken else { return }
              
            let requestUrl = "https://openapi.naver.com/v1/nid/me"
            let url = URL(string: requestUrl)!
            
            let authorization = "\(tokenType) \(accessToken)"
            
            let req = AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization": authorization])
            
            req.responseJSON { response in
              
              guard let body = response.value as? [String: Any] else { return }
                
                if let resultCode = body["message"] as? String{
                    if resultCode.trimmingCharacters(in: .whitespaces) == "success"{
                        let resultJson = body["response"] as! [String: Any]
                        
                        let name = resultJson["name"] as? String ?? ""
                        let id = resultJson["id"] as? String ?? ""
//                        let phone = resultJson["mobile"] as! String
//                        let gender = resultJson["gender"] as? String ?? ""
//                        let birthyear = resultJson["birthyear"] as? String ?? ""
//                        let birthday = resultJson["birthday"] as? String ?? ""
//                        let profile = resultJson["profile_image"] as? String ?? ""
//                        let email = resultJson["email"] as? String ?? ""
//                        let nickName = resultJson["nickname"] as? String ?? ""
                      
                    
                        self.snsLogin(type: .naver, id: id)
                    }
                    else{
                        //실패
                    }
                }
            }
      }
  func kakao(){
    if (KakaoSDKUser.UserApi.isKakaoTalkLoginAvailable()) {
      // 카카오톡 로그인. api 호출 결과를 클로저로 전달.
      KakaoSDKUser.UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
        if let error = error {
          // 예외 처리 (로그인 취소 등)
          print(error)
          KakaoSDKUser.UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
            if let error = error {
              print(error)
            }
            else {
              print("loginWithKakaoAccount() success.")
              //do something
              _ = oauthToken
              self.setUserInfo(token: oauthToken?.accessToken ?? "")
            }
          }
        }
        else {
          print("loginWithKakaoTalk() success.")
          // do something
          _ = oauthToken
          self.setUserInfo(token: oauthToken?.accessToken ?? "")
          // 액세스토큰
        }
      }
    } else {
      KakaoSDKUser.UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
        if let error = error {
          print(error)
        }
        else {
          print("loginWithKakaoAccount() success.")
          //do something
          _ = oauthToken
          self.setUserInfo(token: oauthToken?.accessToken ?? "")
        }
      }
    }
  }
  
  func setUserInfo(token: String) {
    KakaoSDKUser.UserApi.shared.me() { [self](user, error) in
      if let error = error {
        print(error)
      }
      else {
        _ = user
        self.snsLogin(type: .kakao, id: "\(user?.id ?? 0)")
        print("me() success.\(user)")
      }
    }
  }
}
extension LoginViewController: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // Handle successful authorization
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
          
          self.snsLogin(type: .apple, id: userIdentifier)
            // Use the user identifier, full name, and email as needed
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

extension LoginViewController: NaverThirdPartyLoginConnectionDelegate {
  // 로그인 버튼을 눌렀을 경우 열게 될 브라우저
  func oauth20ConnectionDidOpenInAppBrowser(forOAuth request: URLRequest!) {
  }
  
  // 로그인에 성공했을 경우 호출
  func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
    print("[Success] : Success Naver Login")
    naverLoginPaser()
  }
  
  // 접근 토큰 갱신
  func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
    print("!!")
  }
  
  // 로그아웃 할 경우 호출(토큰 삭제)
  func oauth20ConnectionDidFinishDeleteToken() {
    loginInstance?.requestDeleteToken()
  }
  
  // 모든 Error
  func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
    print("[Error] :", error.localizedDescription)
  }
}
extension LoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error)
            return
        }
        guard let authentication = user.authentication else { return }
      print(user.userID)
      self.snsLogin(type: .google, id: user.userID)
        // 서버에 토큰을 보내기. 이 때 idToken, accessToken 차이에 주의할 것
    }
}
