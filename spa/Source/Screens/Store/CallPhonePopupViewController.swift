//
//  CallPhonePopupViewController.swift
//  spa
//
//  Created by 이남기 on 2023/06/29.
//

import Foundation
import UIKit

protocol CallPhoneDelgate: AnyObject {
  func TapCall()
}

class CallPhonePopupViewController: BaseViewController {

  @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
  @IBOutlet var numlabel: UILabel!
  @IBOutlet var callButton: UIButton!
  var phoneNum : String = ""
  weak var delegate: CallPhoneDelgate?

  override func viewDidLoad() {
    super.viewDidLoad()
    bottomConstraint.constant = -210
    numlabel.text = phoneNum
    callButton.rx.tap
      .bind(onNext: { [weak self] _ in
        self?.dismiss(animated: false, completion: {
          self?.delegate?.TapCall()
        })
      })
      .disposed(by: disposeBag)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
//
    bottomConstraint.constant = 0
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
}
