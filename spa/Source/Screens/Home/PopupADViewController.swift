//
//  PopupADViewController.swift
//  spa
//
//  Created by 이동석 on 2022/11/30.
//

import UIKit

protocol PopupADDelegate: AnyObject {
  func didSelectAdvertisement(_ advertisement: Advertisement)
}

class PopupADViewController: BaseViewController {
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var neverButton: UIButton!
  @IBOutlet var closeButton: UIButton!
  @IBOutlet var exitButton: UIImageView!
  
  weak var delegate: PopupADDelegate?

  var advertisement: Advertisement!

  override func viewDidLoad() {
    super.viewDidLoad()

    if let url = URL(string: advertisement.thumbnail) {
      imageView.kf.setImage(with: url)
    }

    imageView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.dismiss(animated: false) {
        self.delegate?.didSelectAdvertisement(self.advertisement)
        }
      })
      .disposed(by: disposeBag)
    
    exitButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.dismiss(animated: false) {
        }
      })
      .disposed(by: disposeBag)


    closeButton.rx.tap
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.dismiss(animated: false)
        self.delegate?.didSelectAdvertisement(self.advertisement)
      })
      .disposed(by: disposeBag)

    neverButton.rx.tap
      .bind(onNext: { [weak self] _ in
        DataHelper.set(true, forKey: .neverShowPopup)
        self?.dismiss(animated: false)
      })
      .disposed(by: disposeBag)
  }
}
