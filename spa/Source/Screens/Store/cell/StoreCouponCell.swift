//
//  StoreCouponCell.swift
//  spa
//
//  Created by 이동석 on 2023/01/31.
//

import UIKit

class StoreCouponCell: UITableViewCell {
  @IBOutlet var couponImageView: UIImageView!
  @IBOutlet var priceLabel: UILabel!
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var periodLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
