//
//  UnlikeStorePopupViewController.swift
//  spa
//
//  Created by 이동석 on 2023/01/09.
//

import UIKit

protocol UnlikeStorePopupDelegate: AnyObject {
  func didUnlikeButtonTapped(storeId: Int)
}

class UnlikeStorePopupViewController: BaseViewController {
  @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var unlikeButton: UIButton!

  var storeId: Int!

  weak var delegate: UnlikeStorePopupDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()

    bottomConstraint.constant = -210

    unlikeButton.rx.tap
      .bind(onNext: { [weak self] in
        self?.dismiss(animated: false, completion: {
          self?.delegate?.didUnlikeButtonTapped(storeId: self?.storeId ?? 0)
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
