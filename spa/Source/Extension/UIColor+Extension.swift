import UIKit

let primaryColor = UIColor(hex: "#db38f5")
let secondaryColor = UIColor(hex: "#FFAE43")

extension UIColor {
  public convenience init?(hexa: String) {
    let r, g, b, a: CGFloat

    if hexa.hasPrefix("#") {
      let start = hexa.index(hexa.startIndex, offsetBy: 1)
      let hexColor = String(hexa[start...])

      if hexColor.count == 8 {
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
          r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
          g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
          b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
          a = CGFloat(hexNumber & 0x000000ff) / 255

          self.init(red: r, green: g, blue: b, alpha: a)
          return
        }
      }
    }

    return nil
  }

  convenience init(hex: String, alpha: CGFloat = 1.0) {
    var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

    if hexFormatted.hasPrefix("#") {
      hexFormatted = String(hexFormatted.dropFirst())
    }

    assert(hexFormatted.count == 6, "Invalid hex code used.")

    var rgbValue: UInt64 = 0
    Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

    self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
              green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
              blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
              alpha: alpha)
  }

  static func rgb(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
    return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
  }

  var redValue: CGFloat{ return CIColor(color: self).red }
  var greenValue: CGFloat{ return CIColor(color: self).green }
  var blueValue: CGFloat{ return CIColor(color: self).blue }
  var alphaValue: CGFloat{ return CIColor(color: self).alpha }
}

extension UIColor {

  @nonobjc class var enableColor: UIColor {
    return UIColor(hex: "#F3A79F")
  }

  @nonobjc class var disableColor: UIColor {
    return UIColor(hex: "#D2CFCE")
  }

}
