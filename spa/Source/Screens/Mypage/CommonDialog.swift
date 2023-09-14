//
//  CommonDialog.swift
//  Treat
//
//  Created by 이남기 on 2023/09/03.
//

import Foundation

import UIKit

protocol CommonDialogDelegate: AnyObject {
  func didUnlikeButtonTapped(diff: String)
}

class CommonDialog: BaseViewController {
  @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var unlikeButton: UIButton!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet var titleLabel: UILabel!
  
  weak var delegate: CommonDialogDelegate?
  var titleString: String?
  var yesTitle: String?
  var yesHidden: Bool = false

  override func viewDidLoad() {
    super.viewDidLoad()

    titleLabel.text = titleString ?? ""
    unlikeButton.setTitle(yesTitle, for: .normal)
    bottomConstraint.constant = -210
    cancelButton.isHidden = yesHidden

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
