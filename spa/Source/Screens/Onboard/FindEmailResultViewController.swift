//
//  FindEmailResultViewController.swift
//  myrrors
//
//  Created by 이동석 on 2022/10/16.
//

import UIKit

class FindEmailResultViewController: BaseViewController {
  @IBOutlet weak var goLoginButton: UIView!
  @IBOutlet weak var emailLabel: UILabel!

  var email: String!
  override func viewDidLoad() {
    super.viewDidLoad()

    emailLabel.text = email

    goLoginButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        let vc = self.navigationController!.viewControllers.first(where: { $0 is LoginViewController })!
        self.navigationController?.popToViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
  }
}
