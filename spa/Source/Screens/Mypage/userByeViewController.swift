//
//  userByeViewController.swift
//  Treat
//
//  Created by 이남기 on 2023/09/03.
//

import Foundation
import UIKit
class userByeViewController: BaseViewController {
  @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var unlikeButton: UIButton!
  @IBOutlet var titleLabel: UILabel!
  
  var storeId: Int!
  weak var delegate: CommonDialogDelegate?
  var titleString: String?
  var yesTitle: String?

  override func viewDidLoad() {
    super.viewDidLoad()
    bottomConstraint.constant = -210

    unlikeButton.rx.tap
      .bind(onNext: { [weak self] in
        self?.dismiss(animated: false, completion: {
          self?.delegate?.didUnlikeButtonTapped(diff: self?.yesTitle ?? "")
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
