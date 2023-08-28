//
//  SnsJoingViewController.swift
//  spa
//
//  Created by 이남기 on 2023/04/11.
//
import UIKit
import RxSwift
import DropDown

class SnsJoingViewController: BaseViewController {
  @IBOutlet weak var scrollView: UIScrollView!

  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var emailWarnningView: UIView!
  @IBOutlet weak var emailWarnningLabel: UILabel!
  @IBOutlet weak var emailCheckView: UIView!

  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var nameCheckView: UIView!

  @IBOutlet weak var phoneTextField: UITextField!
  @IBOutlet weak var sendAuthCodeButton: UIView!
  @IBOutlet weak var sendAuthCodeButtonLabel: UILabel!

  @IBOutlet weak var authCodeTextField: UITextField!
  @IBOutlet weak var authCodeWarnningView: UIView!
  @IBOutlet weak var authCodeCheckView: UIView!

  @IBOutlet weak var recommendUserTextField: UITextField!

  @IBOutlet weak var termsPrivacyOpenButton: UIButton!
  @IBOutlet weak var termsPrivacyButton: UIImageView!
  @IBOutlet weak var termsPrivacyContentView: UIView!
  @IBOutlet weak var termsPrivacyArrowIcon: UIImageView!

  @IBOutlet weak var nextButton: UIView!
  @IBOutlet weak var nextButtonLabel: UILabel!

  var selectedBrandIdList = [Int]()

  var codeToken: String?
  var phoneToken: String?

//  var gender: RegisterRequest.Gender?

  var isSendAuthCode = false
  var timer = Timer()
  var authCodeTime = 180
  var registRequest: SocialLoginRequest?

  var isConfirmAuthCode = false
  var isCheckTermsPrivacy = false

  let emailCheck = BehaviorSubject<Bool>(value: false)
  let passwordCheck = BehaviorSubject<Bool>(value: false)
  let passwordRepeatCheck = BehaviorSubject<Bool>(value: false)
  let nameCheck = BehaviorSubject<Bool>(value: false)
  let nicknameCheck = BehaviorSubject<Bool>(value: false)
  let phoneCheck = BehaviorSubject<Bool>(value: false)
  let temrsPrivacyCheck = BehaviorSubject<Bool>(value: false)

  override func viewDidLoad() {
    super.viewDidLoad()
    emailWarnningView.isHidden = true
    emailCheckView.isHidden = true
    nameCheckView.isHidden = true
    authCodeWarnningView.isHidden = true
    authCodeCheckView.isHidden = true

    bindInput()
    bindOutput()

//    gender = .male
//    maleButton.borderColor = .black
//    maleButtonLabel.textColor = .black
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    timer.invalidate()
  }

  func bindInput() {
      emailTextField.rx.controlEvent(.editingDidEnd)
        .bind(onNext: { [weak self] in
          guard let self = self else { return }
          let email = self.emailTextField.text!
          let emailValidate = email.validateEmail()
          if !email.isEmpty && !emailValidate {
            self.emailCheck.onNext(false)
            self.emailWarnningLabel.text = "이메일 형식 오류"
            self.emailWarnningView.isHidden = false
            self.emailCheckView.isHidden = true
          } else {
            self.checkEmail()
          }
        })
        .disposed(by: disposeBag)

      emailTextField.rx.controlEvent(.editingDidBegin)
        .bind(onNext: { [weak self] in
          guard let self = self else { return }
          self.emailCheck.onNext(false)
          self.emailWarnningView.isHidden = true
          self.emailCheckView.isHidden = true
        })
        .disposed(by: disposeBag)
    nameTextField.rx.controlEvent(.editingDidEnd)
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.nameCheck.onNext(!self.nameTextField.text!.isEmpty)
        self.nameCheckView.isHidden = self.nameTextField.text!.isEmpty
      })
      .disposed(by: disposeBag)

    nameTextField.rx.controlEvent(.editingDidBegin)
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.nameCheck.onNext(false)
        self.nameCheckView.isHidden = true
      })
      .disposed(by: disposeBag)

    sendAuthCodeButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        self?.sendAuthCode()
      })
      .disposed(by: disposeBag)

    authCodeTextField.rx.controlEvent(.editingDidEnd)
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        if self.isSendAuthCode {
          self.confirmAuthCode()
        }
      })
      .disposed(by: disposeBag)

    authCodeTextField.rx.controlEvent(.editingDidBegin)
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.isConfirmAuthCode = false
        self.authCodeWarnningView.isHidden = true
        self.authCodeCheckView.isHidden = true
      })
      .disposed(by: disposeBag)

    termsPrivacyButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        guard let check = try? self.temrsPrivacyCheck.value() else { return }
        self.temrsPrivacyCheck.onNext(!check)
        self.termsPrivacyButton.image = !check ? UIImage(named: "iconCheckOn") : UIImage(named: "iconCheckOff")
      })
      .disposed(by: disposeBag)

    termsPrivacyOpenButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.termsPrivacyContentView.isHidden = !self.termsPrivacyContentView.isHidden
        self.termsPrivacyArrowIcon.image = self.termsPrivacyContentView.isHidden ? UIImage(named: "iconArrowUp") : UIImage(named: "iconArrowDown")
        if !self.termsPrivacyContentView.isHidden {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.height + self.scrollView.contentInset.bottom)
            self.scrollView.setContentOffset(bottomOffset, animated: true)
          }
        }
        self.view.layoutIfNeeded()
      })
      .disposed(by: disposeBag)

    nextButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.view.endEditing(true)
        if self.emailCheckView.isHidden {
          self.callMSGDialog(message: "이메일을 입력해주세요.")
          return
        }
        guard let phoneToken = self.phoneToken else {
          self.callMSGDialog(message: "핸드폰 인증을 진행해주세요")
          return
        }

        if self.nameTextField.text == ""{
          self.callMSGDialog(message: "실명을 입력해주세요.")
          return
        }

        self.register()
      })
      .disposed(by: disposeBag)
  }

  func checkEmail() {
    showHUD()
    APIService.shared.authAPI.rx.request(.checkEmail(email: emailTextField.text!))
      .filterSuccessfulStatusCodes()
      .subscribe(onSuccess: { response in
        self.dismissHUD()
        self.emailCheck.onNext(true)
        self.emailWarnningView.isHidden = true
        self.emailCheckView.isHidden = false
      }, onFailure: { error in
        self.dismissHUD()
        self.emailCheck.onNext(false)
        self.emailWarnningLabel.text = "중복된 이메일"
        self.emailWarnningView.isHidden = false
        self.emailCheckView.isHidden = true
      })
      .disposed(by: disposeBag)
  }
  func bindOutput() {
    phoneTextField.rx.text.orEmpty
      .map({ $0.validatePhone() })
      .bind(onNext: { [weak self] b in
        guard let self = self else { return }
        self.sendAuthCodeButton.borderColor = b ? .black : UIColor(hex: "#f7f8fa")
        self.sendAuthCodeButtonLabel.textColor = b ? .black : UIColor(hex: "#9298aa")
      })
      .disposed(by: disposeBag)

    Observable.combineLatest(emailCheck, passwordCheck, passwordRepeatCheck, nameCheck, nicknameCheck, phoneCheck, temrsPrivacyCheck)
      .map({ $0 && $1 && $2 && $3 && $4 && $5 && $6 })
      .bind(onNext: { [weak self] b in
        guard let self = self else { return }
      })
      .disposed(by: disposeBag)
  }

  func sendAuthCode() {
    if !phoneTextField.text!.validatePhone() {
      return
    }

    showHUD()
    let param = SendAuthCodeRequest(phone: phoneTextField.text!, type: .register)
    APIService.shared.authAPI.rx.request(.sendAuthCode(param: param))
      .filterSuccessfulStatusCodes()
      .map(SendAuthCodeResponse.self)
      .subscribe(onSuccess: { response in
        self.dismissHUD()
        self.codeToken = response.codeToken
        self.authCodeTextField.text = response.code
        self.isSendAuthCode = true
        self.callMSGDialog(message: "인증번호가 전송되었습니다")
//        self.timer.invalidate()
//        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
//          self.eachSeconds()
//        })
      }, onFailure: { error in
        self.dismissHUD()
        if error.serverMessage == "already_in_use" {
          self.callMSGDialog(message: "이미 가입된 휴대폰 번호입니다")
        } else {
          self.callMSGDialog(message: error.serverMessage ?? "오류가 발생하였습니다\n\(error.localizedDescription)")
        }
      })
      .disposed(by: disposeBag)
  }

  func eachSeconds() {
//    if authCodeTime == 0 {
//      timer.invalidate()
//      timerLabel.isHidden = true
//      authCodeTime = 180
//    } else {
//      timerLabel.isHidden = false
//      let minute = String(format: "%02d", authCodeTime / 60)
//      let second = String(format: "%02d", authCodeTime % 60)
//      timerLabel.text = "\(minute):\(second)"
//      authCodeTime -= 1
//    }
  }

  func confirmAuthCode() {
    guard let codeToken = codeToken else {
      callMSGDialog(message: "인증번호를 먼저 전송해주세요")
      return
    }

    showHUD()
    let param = ConfirmAuthCodeRequest(codeToken: codeToken, code: authCodeTextField.text!)
    APIService.shared.authAPI.rx.request(.confirmAuthCode(param: param))
      .filterSuccessfulStatusCodes()
      .map(ConfirmAuthCodeResponse.self)
      .subscribe(onSuccess: { response in
        self.dismissHUD()
        self.phoneCheck.onNext(true)
        self.isConfirmAuthCode = true
        self.phoneToken = response.phoneToken
        self.phoneTextField.isUserInteractionEnabled = false
        self.authCodeTextField.isUserInteractionEnabled = false
        self.authCodeWarnningView.isHidden = true
        self.authCodeCheckView.isHidden = false
      }, onFailure: { error in
        self.dismissHUD()
        self.isConfirmAuthCode = false
        self.authCodeWarnningView.isHidden = false
        self.authCodeCheckView.isHidden = true
      })
      .disposed(by: disposeBag)
  }
  func register() {
    showHUD()
    guard let check = try? self.temrsPrivacyCheck.value() else { return }
    registRequest?.email = emailTextField.text
    registRequest?.name = nameTextField.text
    registRequest?.phone = phoneTextField.text
    registRequest?.agreeMarketing = check
    registRequest?.recommender = recommendUserTextField.text == "" ? nil : recommendUserTextField.text
    APIService.shared.authAPI.rx.request(.socialLogin(param: registRequest!))
      .filterSuccessfulStatusCodes()
      .map(AuthResponse.self)
      .subscribe(onSuccess: { response in
        self.dismissHUD()
        DataHelper<Int>.set(response.user.id, forKey: .userId)
        DataHelper<String>.set(response.token, forKey: .accessToken)
        self.dismiss(animated: true)
      }, onFailure: { error in
        self.callMSGDialog(message: "오류가 발생하였습니다\n\(error.localizedDescription)")
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
}
