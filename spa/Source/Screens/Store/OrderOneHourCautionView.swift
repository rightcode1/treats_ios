//
//  OrderOneHourCautionView.swift
//  spa
//
//  Created by 이남기 on 2023/05/31.
//

import Foundation
protocol OrderOneHourCautionDelegate: AnyObject {
  func didPaymentButtonTapped()
}

class OrderOneHourCautionView: BaseViewController {
  @IBOutlet var sheetView: UIView!
  var delegate: OrderOneHourCautionDelegate?
  override func viewDidLoad() {
    super.viewDidLoad()
    
    sheetView.layer.cornerRadius = 10
    sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
  }
}
