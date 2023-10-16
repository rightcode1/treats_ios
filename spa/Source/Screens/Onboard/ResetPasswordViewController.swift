//
//  ResetPasswordViewController.swift
//  spa
//
//  Created by 이동석 on 2022/12/03.
//

import UIKit
import RxSwift

class ResetPasswordViewController: BaseViewController {
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var passwordWarnningView: UIView!
  @IBOutlet weak var passwordCheckView: UIView!

  @IBOutlet weak var repeatPasswordTextField: UITextField!
  @IBOutlet weak var repeatPasswordWarnningView: UIView!
  @IBOutlet weak var repeatPasswordCheckView: UIView!

  @IBOutlet weak var nextButton: UIView!
  @IBOutlet weak var nextButtonLabel: UILabel!

  var isFromEditProfile = false

  var email: String!
  var phone: String!
  var phoneToken: String!

  let passwordCheck = BehaviorSubject<Bool>(value: false)
  let repeatPasswordCheck = BehaviorSubject<Bool>(value: false)

  override func viewDidLoad() {
    super.viewDidLoad()

    if isFromEditProfile {
      nextButtonLabel.text = "완료"
    }

    passwordWarnningView.isHidden = true
    passwordCheckView.isHidden = true
    repeatPasswordWarnningView.isHidden = true
    repeatPasswordCheckView.isHidden = true

    bindInput()
    bindOutput()
  }

  func bindInput() {
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

    repeatPasswordTextField.rx.controlEvent(.editingDidEnd)
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        if !self.repeatPasswordTextField.text!.isEmpty, self.repeatPasswordTextField.text! == self.repeatPasswordTextField.text! {
          self.repeatPasswordCheck.onNext(true)
          self.repeatPasswordWarnningView.isHidden = true
          self.repeatPasswordCheckView.isHidden = false
        } else {
          self.repeatPasswordCheck.onNext(false)
          self.repeatPasswordWarnningView.isHidden = false
          self.repeatPasswordCheckView.isHidden = true
        }
      })
      .disposed(by: disposeBag)

    repeatPasswordTextField.rx.controlEvent(.editingDidBegin)
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.repeatPasswordCheck.onNext(false)
        self.repeatPasswordWarnningView.isHidden = true
        self.repeatPasswordCheckView.isHidden = true
      })
      .disposed(by: disposeBag)

    nextButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.resetPassword()
      })
      .disposed(by: disposeBag)
  }

  func bindOutput() {
    Observable.combineLatest(passwordCheck, repeatPasswordCheck)
      .map({ $0 && $1 })
      .bind(onNext: { [weak self] b in
        guard let self = self else { return }
        self.nextButton.isUserInteractionEnabled = b
        self.nextButton.backgroundColor = b ? .black : UIColor(hex: "#e3e6ec")
        self.nextButtonLabel.textColor = b ? .white : UIColor(hex: "#9298AA")
      })
      .disposed(by: disposeBag)
  }

  func resetPassword() {
    let param = ResetPasswordRequest(
      password: passwordTextField.text!,
      email: email,
      phone: phone,
      phoneToken: phoneToken
    )

    showHUD()
    APIService.shared.authAPI.rx.request(.resetPassword(param: param))
      .filterSuccessfulStatusCodes()
      .subscribe(onSuccess: { response in
        self.dismissHUD()
        if self.isFromEditProfile {
          if let vc = self.navigationController?.viewControllers.first(where: { $0 is EditProfileViewController }) {
            self.callOkActionMSGDialog(message: "변경되었습니다") {
              self.navigationController?.popToViewController(vc, animated: true)
            }
          }
        } else {
          let vc = self.storyboard?.instantiateViewController(withIdentifier: "authComplete") as! AuthCompleteViewController
          vc.type = .resetPassword
          self.navigationController?.pushViewController(vc, animated: true)
        }
      }, onFailure: { error in
        self.dismissHUD()
        self.callMSGDialog(message: "이메일 혹은 휴대폰 번호를 확인해주세요")
      })
      .disposed(by: disposeBag)
  }
}
