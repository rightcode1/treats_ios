//
//  KakaoSharePopupViewController.swift
//  spa
//
//  Created by 이남기 on 2023/06/29.
//

import Foundation
import UIKit

protocol KakaoSharePopupDelegate: AnyObject {
  func didTapShare()
}

class KakaoSharePopupViewController: BaseViewController {

  @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
  @IBOutlet var kakaoButton: UIImageView!
  
  weak var delegate: KakaoSharePopupDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    bottomConstraint.constant = -210
    kakaoButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        self?.dismiss(animated: false, completion: {
          self?.delegate?.didTapShare()
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
