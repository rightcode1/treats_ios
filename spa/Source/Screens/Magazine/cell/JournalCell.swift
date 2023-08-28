//
//  JournalCell.swift
//  spa
//
//  Created by 이동석 on 2023/01/15.
//

import UIKit

class JournalCell: UITableViewCell {
  @IBOutlet var contentImageView: UIImageView!
  @IBOutlet var contentImageHeightConstraint: NSLayoutConstraint!
  @IBOutlet var titleHeightConstraint: NSLayoutConstraint!
  @IBOutlet var subTitleHeightConstraint: NSLayoutConstraint!
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var subtitleLabel: UILabel!
  @IBOutlet var descriptionLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()

  }
}
