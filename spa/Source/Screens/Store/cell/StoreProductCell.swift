//
//  StoreProductCell.swift
//  spa
//
//  Created by 이동석 on 2022/11/15.
//

import UIKit

class StoreProductCell: UITableViewCell {
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var cardView: UIView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  func initWithProduct(product: Store.Product) {
    nameLabel.text = product.name
    timeLabel.text = "\(product.time)분 소요"
    priceLabel.text = "\(product.price.formattedDecimalString())원"
  }
}
