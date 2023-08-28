//
//  StoreNoticeCell.swift
//  spa
//
//  Created by 이동석 on 2023/07/23.
//

import UIKit

class StoreNoticeCell: UITableViewCell {
  @IBOutlet var cardView: UIView!
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var createdAtLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  func initWithNotice(_ notice: StoreNotice) {
    cardView.layer.cornerRadius = 10
    cardView.layer.borderWidth = 2
    cardView.layer.borderColor = UIColor(hex: "#f6f6f6").cgColor
    
    titleLabel.text = notice.title
    createdAtLabel.text = Date.dateFromISO8601String(notice.createdAt)!.yyyyMMddDot
  }

}
