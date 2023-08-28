//
//  RecentStoreCell.swift
//  spa
//
//  Created by 이동석 on 2023/01/09.
//

import UIKit

protocol RecentStoreCellDelegate: AnyObject {
  func didDeleteButtonTapped(_ cell: RecentStoreCell)
}

class RecentStoreCell: UITableViewCell {
  @IBOutlet weak var titleImageView: UIImageView!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var introLabel: UILabel!
  @IBOutlet weak var likeButton: UIButton!
  @IBOutlet var ratingLabel: UILabel!

  weak var delegate: RecentStoreCellDelegate?

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  func initWithStore(_ store: Store) {
    if let url = URL(string: store.titleImage) {
      titleImageView.kf.setImage(with: url)
    } else {
      titleImageView.image = nil
    }

    addressLabel.text = store.address
    nameLabel.text = store.name
    introLabel.text = store.summary
    ratingLabel.text = String(format: "%.1f", store.rating)
  }

  @IBAction func deleteButtonTapped(_ sender: Any) {
    delegate?.didDeleteButtonTapped(self)
  }
}
