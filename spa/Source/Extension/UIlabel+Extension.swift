//
//  UIlabel+Extension.swift
//  Treat
//
//  Created by 이남기 on 2023/09/05.
//

import Foundation

extension UILabel {
  func calculateLabelHeight(){
    self.numberOfLines = 0
    let labelSize = self.sizeThatFits(CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
    var frame = self.frame
        frame.size.height = labelSize.height
    self.frame = frame
  }
}
