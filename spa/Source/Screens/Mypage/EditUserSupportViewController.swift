//
//  EditUserSupportViewController.swift
//  spa
//
//  Created by 이동석 on 2022/12/18.
//

import UIKit
import IQKeyboardManagerSwift

class EditUserSupportViewController: BaseViewController {
  @IBOutlet var titleTextField: UITextField!
  @IBOutlet var contentTextView: UITextView!

  @IBOutlet var contentPlaceholder: UILabel!
  @IBOutlet var submitButton: UIButton!

  override func viewWillAppear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = false
    IQKeyboardManager.shared.enable = false
  }
  override func viewWillDisappear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = true
    IQKeyboardManager.shared.enable = true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    contentTextView.text = ""
    contentTextView.textContainerInset = UIEdgeInsets(top: 15-4, left: 10-5, bottom: 15-4, right: 10-5)

    bindInput()
    bindOutput()
  }

  func bindInput() {
    submitButton.rx.tap
      .bind(onNext: { [weak self] in
        self?.postUserSupport()
      })
      .disposed(by: disposeBag)
  }

  func bindOutput() {
    contentTextView.rx.text.orEmpty
      .bind(onNext: { [weak self] text in
        self?.contentPlaceholder.isHidden = !text.isEmpty
      })
      .disposed(by: disposeBag)
  }

  func postUserSupport() {
    if titleTextField.text!.isEmpty {
      callMSGDialog(message: "제목을 입력해주세요")
      return
    }

    if contentTextView.text!.isEmpty {
      callMSGDialog(message: "내용을 입력해주세요")
      return
    }

    let data = PostUserSupportRequest(title: titleTextField.text!, content: contentTextView.text!)
    APIService.shared.userAPI.rx.request(.postUserSupport(data: data))
      .filterSuccessfulStatusCodes()
      .subscribe(onSuccess: { response in
        self.callOkActionMSGDialog(message: "등록되었습니다") {
          self.backPress()
        }
      }, onFailure: { error in
        self.callMSGDialog(message: "오류가 발생하였습니다\n\(error.localizedDescription)")
      })
      .disposed(by: disposeBag)
  }
}
