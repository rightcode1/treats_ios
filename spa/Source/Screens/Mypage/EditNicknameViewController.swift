//
//  EditNicknameViewController.swift
//  spa
//
//  Created by 이동석 on 2023/02/15.
//

import UIKit

class EditNicknameViewController: BaseViewController {
  @IBOutlet weak var nicknameTextField: UITextField!

  @IBOutlet weak var nicknameWarnningView: UIView!
  @IBOutlet weak var nicknameCheckView: UIView!

  @IBOutlet weak var confirmButton: UIView!
  @IBOutlet weak var confirmButtonLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    nicknameWarnningView.isHidden = true
    nicknameCheckView.isHidden = true

    bindInput()
    bindOutput()
  }

  func bindInput() {
    nicknameTextField.rx.controlEvent(.editingDidBegin)
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.nicknameWarnningView.isHidden = true
        self.nicknameCheckView.isHidden = true
        self.enableConfirmButton(false)
      }).disposed(by: disposeBag)

    nicknameTextField.rx.controlEvent(.editingDidEnd)
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        if self.nicknameTextField.text!.isEmpty {
          return
        }
        self.checkNickname()
      }).disposed(by: disposeBag)

    confirmButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.showHUD()
        let param = PatchUserInfoRequest(nickname: self.nicknameTextField.text!)
        APIService.shared.userAPI.rx.request(.patchUserInfo(param: param))
          .filterSuccessfulStatusCodes()
          .subscribe(onSuccess: { response in
            self.dismissHUD()
            self.callOkActionMSGDialog(message: "변경되었습니다") {
              self.backPress()
            }
          }, onFailure: { error in
            self.dismissHUD()
            self.callMSGDialog(message: "오류가 발생했습니다")
          })
          .disposed(by: self.disposeBag)
      })
      .disposed(by: disposeBag)
  }

  func bindOutput() {

  }

  func checkNickname() {
    showHUD()
    APIService.shared.authAPI.rx.request(.checkNickname(nickname: nicknameTextField.text!))
      .filterSuccessfulStatusCodes()
      .subscribe(onSuccess: { response in
        self.dismissHUD()
//        self.nicknameCheck.onNext(true)
        self.nicknameWarnningView.isHidden = true
        self.nicknameCheckView.isHidden = false
        self.enableConfirmButton(true)
      }, onFailure: { error in
        self.dismissHUD()
//        self.nicknameCheck.onNext(false)
        self.nicknameWarnningView.isHidden = false
        self.nicknameCheckView.isHidden = true
        self.enableConfirmButton(false)
      })
      .disposed(by: disposeBag)
  }

  func enableConfirmButton(_ enable: Bool) {
    confirmButton.isUserInteractionEnabled = enable
    confirmButton.backgroundColor = enable ? .black : UIColor(hex: "#F7F8FA")
    confirmButtonLabel.textColor = enable ? .white : UIColor(hex: "#9298AA")
  }
}
