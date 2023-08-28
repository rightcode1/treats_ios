//
//  TermsViewController.swift
//  myrrors
//
//  Created by 이동석 on 2022/10/16.
//

import UIKit

enum TermsType {
  case usage
  case privacy
}

protocol TermsViewControllerDelegate: AnyObject {
  func didAgreeTemrs(type: TermsType)
}

class TermsViewController: BaseViewController {
  @IBOutlet weak var agreeButton: UILabel!
  @IBOutlet weak var titleLabel: UILabel!

  weak var delegate: TermsViewControllerDelegate?

  var termsType = TermsType.usage

  override func viewDidLoad() {
    super.viewDidLoad()

    switch termsType {
    case .usage:
      titleLabel.text = "약 관"
    case .privacy:
      titleLabel.text = "개인정보 처리방침"
    }

    agreeButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.delegate?.didAgreeTemrs(type: self.termsType)
        self.backPress()
      })
      .disposed(by: disposeBag)
  }
}
