//
//  HomeStoreCell.swift
//  spa
//
//  Created by 이동석 on 2023/03/09.
//

import UIKit

class HomeStoreCell: UITableViewCell {
  @IBOutlet var storeImageView: UIImageView!

  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var introLabel: UILabel!
  @IBOutlet var ratingLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

  func initWithStore(_ store: Store) {
    if let url = URL(string: store.titleImage) {
      storeImageView.kf.setImage(with: url)
    } else {
      storeImageView.image = nil
    }

    nameLabel.text = store.name
    introLabel.text = store.summary
    ratingLabel.text = String(format: "%.1f", store.rating)
  }

}
