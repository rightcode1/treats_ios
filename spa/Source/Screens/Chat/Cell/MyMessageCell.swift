//
//  MyMessageCell.swift
//  everydayPay_Admin
//
//  Created by 이남기 on 2023/02/13.
//

import Foundation
import UIKit

class MyMessageCell: UITableViewCell{
  @IBOutlet weak var content: UILabel!
  @IBOutlet weak var time: UILabel!
  
  func initupdate(data: ChatMessage){
    content.text = data.message
    time.text = data.createdAt
  }
  
}
