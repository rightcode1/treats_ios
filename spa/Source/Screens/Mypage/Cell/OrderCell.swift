//
//  OrderCell.swift
//  spa
//
//  Created by 이동석 on 2022/12/05.
//

import UIKit

protocol OrderCellDelegate: AnyObject {
  func didDetailButtonTapped(_ cell: UITableViewCell)
  func didReviewButtonTapped(_ cell: UITableViewCell)
}

class OrderCell: UITableViewCell {
  @IBOutlet weak var dividerView: UIView!
  @IBOutlet weak var dateView: UIView!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var storeImageView: UIImageView!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var storeAddressLabel: UILabel!
  @IBOutlet weak var storeNameLabel: UILabel!
  @IBOutlet weak var productNameLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var reviewView: UIView!
  
  @IBOutlet var reservationDateLabel: UILabel!
  @IBOutlet var reservationTimeLabel: UILabel!
  @IBOutlet var reservationPeopleLabel: UILabel!
  
  var order : OrderList?

  weak var delegate: OrderCellDelegate?

  override func awakeFromNib() {
    super.awakeFromNib()

  }

  func initWithOrderList(_ order: OrderList) {
    self.order = order
    statusLabel.text = order.status.getString()
    statusLabel.textColor = order.status.getTextColor()
    dateLabel.text = Date.dateFromISO8601String(order.createdAt)?.yyyyMMddDot
    storeImageView.kf.setImage(with: URL(string: order.storeTitleImage)!)
    storeAddressLabel.text = order.storeAddress
    storeNameLabel.text = order.storeName
    
    if order.amount == nil{
      amountLabel.isHidden = true
    }else{
      amountLabel.isHidden = false
      amountLabel.text = "\(order.amount!.formattedDecimalString())원"
    }
    if order.productName == nil{
      productNameLabel.isHidden = true
    }else{
      productNameLabel.isHidden = false
      productNameLabel.text = order.productName //
    }
    
    
    reservationDateLabel.text = order.date
    reservationTimeLabel.text = order.time
    reservationPeopleLabel.text = "\(order.count)명"
  }

  @IBAction func detailButtonTapped(_ sender: Any) {
    if order?.status == .send || order?.status == .wait{
      return
    }
    delegate?.didDetailButtonTapped(self)
  }

  @IBAction func reviewButtonTapped(_ sender: Any) {
    delegate?.didReviewButtonTapped(self)
  }
}
