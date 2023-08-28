//
//  StoreInfoCell.swift
//  spa
//
//  Created by 이동석 on 2023/01/02.
//

import UIKit

class StoreInfoCell: UITableViewCell {

  @IBOutlet var restDayLabel: UILabel!
  @IBOutlet var doDayLabel: UILabel!
  @IBOutlet var surveyLabel: UILabel!
  @IBOutlet var parkLabel: UILabel!
  @IBOutlet var launchLabel: UILabel!
  @IBOutlet var coupleRoomLabel: UILabel!
  
  @IBOutlet var coupleRoomView: UIView!
  @IBOutlet var restDayView: UIView!
  @IBOutlet var launchView: UIView!
  @IBOutlet var doDayView: UIView!
  @IBOutlet var surveyView: UIView!
  @IBOutlet var parkView: UIView!
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
}
