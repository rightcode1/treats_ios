//
//  AuthCompleteViewController.swift
//  spa
//
//  Created by 이동석 on 2022/12/03.
//

import UIKit

enum AuthCompleteType {
  case register
  case resetPassword
}

class AuthCompleteViewController: BaseViewController {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var goLoginButton: UIView!

  var type: AuthCompleteType = .register

  override func viewDidLoad() {
    super.viewDidLoad()

    switch type {
    case .register:
      titleLabel.text = "회원가입 완료!"
      descriptionLabel.text = "스파 설렉션에서 다양한 스파를 경험하세요."
    case .resetPassword:
      titleLabel.text = "비밀번호 변경 완료!"
      descriptionLabel.text = "지금 바로 아름다움을 경험해 보세요!"
    }

    goLoginButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        let vc = self.navigationController!.viewControllers.first(where: { $0 is LoginViewController })!
        self.navigationController?.popToViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
  }
}
