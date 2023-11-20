//
//  UIPageControl+Extension.swift
//  spa
//
//  Created by 이동석 on 2023/03/07.
//

import Foundation

extension UIPageControl {

  func customPageControl(dotFillColor:UIColor, dotBorderColor:UIColor, dotBorderWidth:CGFloat) {
    for (pageIndex, dotView) in self.subviews.enumerated() {
      if self.currentPage == pageIndex {
        dotView.backgroundColor = dotFillColor
        dotView.layer.cornerRadius = dotView.frame.size.height / 2
      }else{
        dotView.backgroundColor = .clear
        dotView.layer.cornerRadius = dotView.frame.size.height / 2
        dotView.layer.borderColor = dotBorderColor.cgColor
        dotView.layer.borderWidth = dotBorderWidth
      }
    }
  }

}
