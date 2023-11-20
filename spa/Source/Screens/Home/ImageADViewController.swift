//
//  ImageADViewController.swift
//  spa
//
//  Created by 이동석 on 2022/11/30.
//

import UIKit
import Kingfisher

class ImageADViewController: BaseViewController {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet var thumbnailImageViewHeight: NSLayoutConstraint!
  
  var advertisement: Advertisement!
  
  override func viewWillAppear(_ animated: Bool) {
    self.showHUD()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.titleLabel.text = advertisement.name
    if let url = URL(string: advertisement.detailImage ?? "") {
      KingfisherManager.shared.retrieveImage(with: url) { result in
        switch result {
        case .success(let image):
          let image = image.image.resizeToWidth(newWidth: UIScreen.main.bounds.width)
          self.thumbnailImageViewHeight.constant = image.size.height
          self.imageView.image = image
          self.dismissHUD()
        case .failure(let error):
          log.error(error)
          break
        }
      }
    }
  }
}
