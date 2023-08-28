//
//  HomeBannerCell.swift
//  spa
//
//  Created by 이동석 on 2023/02/13.
//

import UIKit
import FSPagerView

class HomeBannerCell: FSPagerViewCell {
  @IBOutlet var bannerImageView: UIImageView!
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var titleWidthConstraint: NSLayoutConstraint!

  @IBOutlet var subTitleLabel: UILabel!
  @IBOutlet var subTitleWidthConstraint: NSLayoutConstraint!

  @IBOutlet var categoryLabel: UILabel!
  @IBOutlet var gradientView: UIView!

  override func awakeFromNib() {
    super.awakeFromNib()
    
    titleWidthConstraint.constant = (UIScreen.main.bounds.width / 2) - 20
    subTitleWidthConstraint.constant = (UIScreen.main.bounds.width / 2) - 20
  }
}
