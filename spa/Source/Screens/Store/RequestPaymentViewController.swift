//
//  RequestPaymentViewController.swift
//  spa
//
//  Created by 이동석 on 2022/11/15.
//

import UIKit

protocol RequestPaymentDelegate: AnyObject {
  func didPaymentButtonTapped()
}

class RequestPaymentViewController: BaseViewController {
  @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

  @IBOutlet weak var paymentButton: UIButton!
  weak var delegate: RequestPaymentDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()

    bottomConstraint.constant = -390

    paymentButton.rx.tap
      .bind(onNext: { [weak self] in
        self?.dismiss(animated: false, completion: {
          self?.delegate?.didPaymentButtonTapped()
        })
      })
      .disposed(by: disposeBag)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    bottomConstraint.constant = 0
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
}
