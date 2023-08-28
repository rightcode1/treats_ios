//
//  NoOrderOneHourView.swift
//  spa
//
//  Created by 이남기 on 2023/05/31.
//

import Foundation

class NoOrderOneHourView : BaseViewController{
  
  @IBOutlet var sheetView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    sheetView.layer.cornerRadius = 10
    sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
  }
}
