//
//  ProductCell.swift
//  spa
//
//  Created by 이동석 on 2023/01/04.
//

import UIKit

class ProductCell: UITableViewCell {
  @IBOutlet var headerView: UIView!
  @IBOutlet var headerLabel: UILabel!

  @IBOutlet var cardView: UIView!
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var timeLabel: UILabel!
  @IBOutlet var priceLabel: UILabel!
  @IBOutlet var contentLabel: UILabel!
  @IBOutlet var unavailableBadge: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  func initWithCategoryNameAndProduct(categoryName: String, product: Store.Product) {

  }
}
