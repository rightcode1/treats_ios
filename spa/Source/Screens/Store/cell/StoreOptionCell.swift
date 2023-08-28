//
//  StoreOptionCell.swift
//  spa
//
//  Created by 이동석 on 2022/11/28.
//

import UIKit

protocol StoreOptionCellDelegate: AnyObject {
  func didPlusButtonTapped(_ cell: StoreOptionCell)
  func didMinusButtonTapped(_ cell: StoreOptionCell)
}

class StoreOptionCell: UITableViewCell {
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var quantityLabel: UILabel!

  @IBOutlet weak var plusButton: UIButton!
  @IBOutlet weak var minusButton: UIButton!

  weak var delegate: StoreOptionCellDelegate?

  override func awakeFromNib() {
    super.awakeFromNib()

  }

  @IBAction func plusButtonTapped(_ sender: Any) {
    delegate?.didPlusButtonTapped(self)
  }

  @IBAction func minusButtonTapped(_ sender: Any) {
    delegate?.didMinusButtonTapped(self)
  }
}
