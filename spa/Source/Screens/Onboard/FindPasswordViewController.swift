//
//  FindPasswordViewController.swift
//  myrrors
//
//  Created by 이동석 on 2022/10/16.
//

import UIKit

class FindPasswordViewController: BaseViewController {
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var phoneTextField: UITextField!
  @IBOutlet weak var sendAuthCodeButton: UIView!
  @IBOutlet weak var sendAuthCodeButtonLabel: UILabel!
  @IBOutlet weak var inputAuthCodeView: UIView!
  @IBOutlet weak var authCodeTextField: UITextField!
  @IBOutlet weak var authCodeWarnningView: UIView!
  @IBOutlet weak var authCodeCheckView: UIView!
  @IBOutlet weak var nextButton: UIView!
  @IBOutlet weak var nextButtonLabel: UILabel!

  var isFromEditProfile = false

  var codeToken: String?
  var phoneToken: String?

  override func viewDidLoad() {
    super.viewDidLoad()

    inputAuthCodeView.isHidden = true
    authCodeWarnningView.isHidden = true
    authCodeCheckView.isHidden = true

    bindInput()
    bindOutput()
  }

  func bindInput() {
    sendAuthCodeButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        self?.sendAuthCode()
      })
      .disposed(by: disposeBag)

    authCodeTextField.rx.controlEvent(.editingDidEnd)
      .bind(onNext: { [weak self] in
        self?.confirmAuthCode()
      })
      .disposed(by: disposeBag)

    nextButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.checkUser()
        
        
      })
      .disposed(by: disposeBag)
  }

  func bindOutput() {
    phoneTextField.rx.text.orEmpty
      .map({ $0.validatePhone() })
      .bind(onNext: { [weak self] b in
        guard let self = self else { return }
        self.sendAuthCodeButton.isUserInteractionEnabled = b
        self.sendAuthCodeButton.borderColor = b ? .black : UIColor(hex: "#c6c6c8")
        self.sendAuthCodeButtonLabel.textColor = b ? .black : UIColor(hex: "#2d2d2d")
      })
      .disposed(by: disposeBag)
  }

  func sendAuthCode() {
    if !phoneTextField.text!.validatePhone() {
      callMSGDialog(message: "정확한 휴대전화번호를 입력해주세요")
      return
    }

    showHUD()
    let param = SendAuthCodeRequest(phone: phoneTextField.text!, type: .resetPassword)
    APIService.shared.authAPI.rx.request(.sendAuthCode(param: param))
      .filterSuccessfulStatusCodes()
      .map(SendAuthCodeResponse.self)
      .subscribe(onSuccess: { response in
        self.dismissHUD()
        self.codeToken = response.codeToken
        self.authCodeTextField.text = response.code
        self.inputAuthCodeView.isHidden = false
        self.callMSGDialog(message: "인증번호가 전송되었습니다")
      }, onFailure: { error in
        self.dismissHUD()
        self.callMSGDialog(message: error.serverMessage ?? "오류가 발생하였습니다\n\(error.localizedDescription)")
      })
      .disposed(by: disposeBag)
  }
  func checkUser() {
    if !phoneTextField.text!.validatePhone() {
      callMSGDialog(message: "정확한 휴대전화번호를 입력해주세요")
      return
    }
    guard let codeToken = codeToken else {
      callMSGDialog(message: "인증번호를 먼저 전송해주세요")
      return
    }
    showHUD()
    APIService.shared.userAPI.rx.request(.checkUser(id: emailTextField.text!, pwd: phoneTextField.text!))
      .filterSuccessfulStatusCodes()
      .subscribe(onSuccess: { response in
        self.dismissHUD()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "resetPassword") as! ResetPasswordViewController
        vc.isFromEditProfile = self.isFromEditProfile
        vc.email = self.emailTextField.text!
        vc.phone = self.phoneTextField.text!
        vc.phoneToken = self.phoneToken
        self.navigationController?.pushViewController(vc, animated: true)
      }, onFailure: { error in
        self.dismissHUD()
        self.callMSGDialog(message: "이메일 혹은 휴대폰번호를 확인해주세요.")
      })
      .disposed(by: disposeBag)
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
        self.phoneToken = response.phoneToken
        self.phoneTextField.isUserInteractionEnabled = false
        self.authCodeTextField.isUserInteractionEnabled = false
        self.authCodeWarnningView.isHidden = true
        self.authCodeCheckView.isHidden = false
        self.nextButton.isUserInteractionEnabled = true
        self.nextButton.backgroundColor = .black
        self.nextButtonLabel.textColor = .white
      }, onFailure: { error in
        self.dismissHUD()
        self.authCodeWarnningView.isHidden = false
        self.authCodeCheckView.isHidden = true
      })
      .disposed(by: disposeBag)
  }
}
