//
//  StoreInfoCell.swift
//  spa
//
//  Created by 이동석 on 2023/01/02.
//

import UIKit

class ImageInfoCell: UITableViewCell {
  @IBOutlet var infoImageView: UIImageView!
  @IBOutlet var infoImageViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var descriptionLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

  }
}
