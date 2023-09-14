import Foundation
import UIKit

extension UIImage{

  convenience init(view: UIView) {
    UIGraphicsBeginImageContextWithOptions(view.frame.size, false, UIScreen.main.scale)
    view.layer.render(in:UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    self.init(cgImage: image!.cgImage!)
  }

  func resize(to size: CGSize) -> UIImage? {
    // Actually do the resizing to the rect using the ImageContext stuff
    let aspect = self.size.width / self.size.height
    var rect = CGRect.zero
    if (size.width / aspect) > size.height{
      let height = size.width / aspect
      rect = CGRect(
        x: 0,
        y: size.height - height,
        width: size.width,
        height: height
      )
    } else {
      let width = size.height * aspect
      rect = CGRect(
        x: size.width - width,
        y: 0,
        width: width,
        height: size.height
      )
    }

    UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
    UIGraphicsGetCurrentContext()?.clip(to: CGRect(origin: CGPoint.zero, size: size))
    UIGraphicsGetCurrentContext()?.setFillColor(UIColor.black.cgColor)
    self.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage
  }

  func resizeToWidth(newWidth: CGFloat) -> UIImage {
    // 300 보다 작으면 리사이즈 필요 없음
//    if self.size.width < 750 {
//      return self
//    }
    let scale = newWidth / self.size.width
    let newHeight = self.size.height * scale
    //      UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 2.0)
    self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
  }

  func asBase64() -> String?{
    let data = self.jpegData(compressionQuality: 1)

    return data?.base64EncodedString()
  }

  convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)){
    let rect = CGRect(origin: .zero, size: size)

    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
    color.setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    guard let cgImage = image?.cgImage else{ return nil }
    self.init(cgImage: cgImage)
  }

  class func imageWithColor(color: UIColor) -> UIImage {
    let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.5)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    color.setFill()
    UIRectFill(rect)
    let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image
  }
}

extension UIImage {

  /// Creates a circular outline image.
  class func outlinedEllipse(size: CGSize, color: UIColor, lineWidth: CGFloat = 0.5) -> UIImage? {

    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    guard let context = UIGraphicsGetCurrentContext() else {
      return nil
    }

    context.setStrokeColor(color.cgColor)
    context.setLineWidth(lineWidth)
    // Inset the rect to account for the fact that strokes are
    // centred on the bounds of the shape.
    let rect = CGRect(origin: .zero, size: size).insetBy(dx: lineWidth * 0.5, dy: lineWidth * 0.5)
    context.addEllipse(in: rect)
    context.strokePath()

    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }
  }
