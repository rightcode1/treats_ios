//
//  RegisterViewController.swift
//  myrrors
//
//  Created by 이동석 on 2022/10/14.
//

import UIKit
import RxSwift
import DropDown

class RegisterViewController: BaseViewController {
  @IBOutlet weak var scrollView: UIScrollView!

  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var emailWarnningView: UIView!
  @IBOutlet weak var emailWarnningLabel: UILabel!
  @IBOutlet weak var emailCheckView: UIView!

  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var passwordWarnningView: UIView!
  @IBOutlet weak var passwordCheckView: UIView!

  @IBOutlet weak var passwordRepeatTextField: UITextField!
  @IBOutlet weak var passwordRepeatWarnningView: UIView!
  @IBOutlet weak var passwordRepeatCheckView: UIView!

  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var nameCheckView: UIView!

  @IBOutlet weak var nicknameTextField: UITextField!
  @IBOutlet weak var nicknameWarnningView: UIView!
  @IBOutlet weak var nicknameCheckView: UIView!

  @IBOutlet weak var phoneTextField: UITextField!
  @IBOutlet weak var sendAuthCodeButton: UIView!
  @IBOutlet weak var sendAuthCodeButtonLabel: UILabel!

  @IBOutlet weak var authCodeTextField: UITextField!
  @IBOutlet weak var authCodeWarnningView: UIView!
  @IBOutlet weak var authCodeCheckView: UIView!

  @IBOutlet weak var recommendUserTextField: UITextField!
  @IBOutlet weak var recommendWarnningView: UIView!
  @IBOutlet weak var recommendCheckView: UIView!

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
  var recommandCheck = false

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
    passwordWarnningView.isHidden = true
    passwordCheckView.isHidden = true
    passwordRepeatWarnningView.isHidden = true
    passwordRepeatCheckView.isHidden = true
    nameCheckView.isHidden = true
    nicknameWarnningView.isHidden = true
    nicknameCheckView.isHidden = true
    authCodeWarnningView.isHidden = true
    authCodeCheckView.isHidden = true
    recommendWarnningView.isHidden = true
    recommendCheckView.isHidden = true

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

    passwordTextField.rx.controlEvent(.editingDidEnd)
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let password = self.passwordTextField.text!
        let passwordValidate = password.validatePassword()
        if !password.isEmpty && !passwordValidate {
          self.passwordCheck.onNext(false)
          self.passwordCheckView.isHidden = true
          self.passwordWarnningView.isHidden = false
        } else {
          self.passwordCheck.onNext(true)
          self.passwordCheckView.isHidden = false
          self.passwordWarnningView.isHidden = true
        }
      })
      .disposed(by: disposeBag)

    passwordTextField.rx.controlEvent(.editingDidBegin)
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.passwordCheck.onNext(false)
        self.passwordCheckView.isHidden = true
        self.passwordWarnningView.isHidden = true
      })
      .disposed(by: disposeBag)

    passwordRepeatTextField.rx.controlEvent(.editingDidEnd)
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        if !self.passwordRepeatTextField.text!.isEmpty, self.passwordTextField.text! == self.passwordRepeatTextField.text! {
          self.passwordRepeatCheck.onNext(true)
          self.passwordRepeatWarnningView.isHidden = true
          self.passwordRepeatCheckView.isHidden = false
        } else {
          self.passwordRepeatCheck.onNext(false)
          self.passwordRepeatWarnningView.isHidden = false
          self.passwordRepeatCheckView.isHidden = true
        }
      })
      .disposed(by: disposeBag)

    passwordRepeatTextField.rx.controlEvent(.editingDidBegin)
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.passwordRepeatCheck.onNext(false)
        self.passwordRepeatWarnningView.isHidden = true
        self.passwordRepeatCheckView.isHidden = true
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

    nicknameTextField.rx.controlEvent(.editingDidEnd)
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let nickname = self.nicknameTextField.text!
        if !nickname.isEmpty {
          self.checkNickname()
        } else {
          self.nicknameCheck.onNext(false)
          self.nicknameWarnningView.isHidden = true
          self.nicknameCheckView.isHidden = true
        }
      })
      .disposed(by: disposeBag)

    nicknameTextField.rx.controlEvent(.editingDidBegin)
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.nicknameCheck.onNext(false)
        self.nicknameWarnningView.isHidden = true
        self.nicknameCheckView.isHidden = true
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

//    maleButton.rx.tapGesture().when(.recognized)
//      .bind(onNext: { [weak self] _ in
//        guard let self = self else { return }
//        self.maleButton.borderColor = .black
//        self.maleButtonLabel.textColor = .black
//        self.femaleButton.borderColor = UIColor(hex: "#f7f8fa")
//        self.femaleButtonLabel.textColor = UIColor(hex: "#9298aa")
//        self.gender = .male
//      })
//      .disposed(by: disposeBag)
//
//    femaleButton.rx.tapGesture().when(.recognized)
//      .bind(onNext: { [weak self] _ in
//        guard let self = self else { return }
//        self.maleButton.borderColor = UIColor(hex: "#f7f8fa")
//        self.maleButtonLabel.textColor = UIColor(hex: "#9298aa")
//        self.femaleButton.borderColor = .black
//        self.femaleButtonLabel.textColor = .black
//        self.gender = .female
//      })
//      .disposed(by: disposeBag)

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
    
    recommendUserTextField.rx.controlEvent(.editingDidEnd)
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let recommendUser = self.recommendUserTextField.text!
        if !recommendUser.isEmpty {
          self.checkRecommend()
        } else {
          self.recommandCheck = false
          self.recommendWarnningView.isHidden = true
          self.recommendCheckView.isHidden = true
        }
      })
      .disposed(by: disposeBag)

    recommendUserTextField.rx.controlEvent(.editingDidBegin)
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.recommandCheck = false
        self.recommendWarnningView.isHidden = true
        self.recommendCheckView.isHidden = true
      })
      .disposed(by: disposeBag)

    nextButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.register()
      })
      .disposed(by: disposeBag)
  }

  func bindOutput() {
    phoneTextField.rx.text.orEmpty
      .map({ $0.validatePhone() })
      .bind(onNext: { [weak self] b in
        guard let self = self else { return }
        self.sendAuthCodeButton.borderColor = b ? .black : UIColor(hex: "#c6c6c8")
        self.sendAuthCodeButtonLabel.textColor = b ? .black : UIColor(hex: "#2d2d2d")
      })
      .disposed(by: disposeBag)

    Observable.combineLatest(emailCheck, passwordCheck, passwordRepeatCheck, nameCheck, nicknameCheck, phoneCheck, temrsPrivacyCheck)
      .map({ $0 && $1 && $2 && $3 && $4 && $5 && $6})
      .bind(onNext: { [weak self] b in
        guard let self = self else { return }
        self.nextButton.isUserInteractionEnabled = b
        self.nextButton.backgroundColor = b ? .black : UIColor(hex: "#e3e6ec")
        self.nextButtonLabel.textColor = b ? .white : UIColor(hex: "#9298AA")
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

  func checkNickname() {
    showHUD()
    APIService.shared.authAPI.rx.request(.checkNickname(nickname: nicknameTextField.text!))
      .filterSuccessfulStatusCodes()
      .subscribe(onSuccess: { response in
        self.dismissHUD()
        self.nicknameCheck.onNext(true)
        self.nicknameWarnningView.isHidden = true
        self.nicknameCheckView.isHidden = false
      }, onFailure: { error in
        self.dismissHUD()
        self.nicknameCheck.onNext(false)
        self.nicknameWarnningView.isHidden = false
        self.nicknameCheckView.isHidden = true
      })
      .disposed(by: disposeBag)
  }
  func checkRecommend() {
    showHUD()
    APIService.shared.authAPI.rx.request(.checkNickname(nickname: recommendUserTextField.text!))
      .filterSuccessfulStatusCodes()
      .subscribe(onSuccess: { response in
        self.dismissHUD()
        self.recommandCheck = false
        self.recommendWarnningView.isHidden = false
        self.recommendCheckView.isHidden = true
      }, onFailure: { error in
        self.dismissHUD()
        self.recommandCheck = true
        self.recommendWarnningView.isHidden = true
        self.recommendCheckView.isHidden = false
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

    view.endEditing(true)

    guard let phoneToken = phoneToken else {
      callMSGDialog(message: "핸드폰 인증을 진행해주세요")
      return
    }

    if emailCheckView.isHidden {
      return
    }

    if nicknameCheckView.isHidden {
      return
    }
    if recommendUserTextField.text != "" && !recommandCheck{
      return
    }
//
    let param = RegisterRequest(
      email: emailTextField.text!,
      name: nameTextField.text!,
      nickname: nicknameTextField.text!,
      phone: phoneTextField.text!,
      gender: nil,
      type: .email,
      password: passwordTextField.text!,
      phoneToken: phoneToken,
      recommender: recommendUserTextField.text ?? ""
    )
    showHUD()
    APIService.shared.authAPI.rx.request(.register(param: param))
      .filterSuccessfulStatusCodes()
      .subscribe(onSuccess: { response in
        self.dismissHUD()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "authComplete") as! AuthCompleteViewController
        vc.type = .register
        self.navigationController?.pushViewController(vc, animated: true)
      }, onFailure: { error in
        self.dismissHUD()
        self.callMSGDialog(message: "오류가 발생하였습니다\n\(error.localizedDescription)")
      })
      .disposed(by: disposeBag)
  }
}
