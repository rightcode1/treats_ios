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
    if self.text!.contains("\n") {
       let fontHeight = self.font.lineHeight // 폰트의 높이 가져오기
        let lines = (self.text?.components(separatedBy: "\n").count ?? 1) - 1
      frame.size.height = CGFloat(lines) * fontHeight + labelSize.height
    }
    self.frame = frame
  }
}
