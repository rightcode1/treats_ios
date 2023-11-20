//
//  UIFont+Extension.swift
//  ginger9
//
//  Created by jason on 2021/08/25.
//

import Foundation
import UIKit

struct NotoSansKR {
  static let regular = "NotoSansKR-Regular"
  static let medium = "NotoSansKR-Medium"
  static let bold = "NotoSansKR-Bold"
}

extension UIFontDescriptor.AttributeName {
  static let nsctFontUIUsage = UIFontDescriptor.AttributeName(rawValue: "NSCTFontUIUsageAttribute")
}

extension UIFont {

  @objc class func mySystemFont(ofSize size: CGFloat) -> UIFont {
    return UIFont(name: NotoSansKR.regular, size: size)!
  }

  @objc class func myBoldSystemFont(ofSize size: CGFloat) -> UIFont {
    return UIFont(name: NotoSansKR.bold, size: size)!
  }

  @objc convenience init(myCoder aDecoder: NSCoder) {
    if let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor {
      if let fontAttribute = fontDescriptor.fontAttributes[.nsctFontUIUsage] as? String {
        var fontName = ""
        switch fontAttribute {
        case "CTFontRegularUsage":
          fontName = NotoSansKR.regular
        case "CTFontEmphasizedUsage":
          fontName = NotoSansKR.medium
        case "CTFontBoldUsage":
          fontName = NotoSansKR.bold
        default:
          fontName = NotoSansKR.regular
        }
        self.init(name: fontName, size: fontDescriptor.pointSize)!
      }
      else {
        self.init(myCoder: aDecoder)
      }
    }
    else {
      self.init(myCoder: aDecoder)
    }
  }

  class func overrideInitialize() {
    if self == UIFont.self {
      let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:)))
      let mySystemFontMethod = class_getClassMethod(self, #selector(mySystemFont(ofSize:)))
      method_exchangeImplementations(systemFontMethod!, mySystemFontMethod!)

      let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:)))
      let myBoldSystemFontMethod = class_getClassMethod(self, #selector(myBoldSystemFont(ofSize:)))
      method_exchangeImplementations(boldSystemFontMethod!, myBoldSystemFontMethod!)

//      let mediumSystemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:weight:)))
//      let myMediumSystemFontMethod = class_getClassMethod(self, #selector(myMediumSystemFont(ofSize:)))
//      method_exchangeImplementations(mediumSystemFontMethod!, myMediumSystemFontMethod!)

      let initCoderMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))) // Trick to get over the lack of UIFont.init(coder:))
      let myInitCoderMethod = class_getInstanceMethod(self, #selector(UIFont.init(myCoder:)))
      method_exchangeImplementations(initCoderMethod!, myInitCoderMethod!)
    }
  }
}
