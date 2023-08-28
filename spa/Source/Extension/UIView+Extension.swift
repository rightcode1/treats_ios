import UIKit

extension UIView {
  func applyGradient(colors: [UIColor]) {
    applyGradient(colors: colors, locations: nil)
  }

  func applyGradient(colors: [UIColor], locations: [NSNumber]? = nil, startPoint: CGPoint? = nil, endPoint: CGPoint? = nil) -> Void {
    layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
    let gradient: CAGradientLayer = CAGradientLayer()
    gradient.frame = self.bounds
    gradient.colors = colors.map { $0.cgColor }
    gradient.locations = locations
    gradient.startPoint = startPoint ?? CGPoint(x: 0.5, y: 0)
    gradient.endPoint = endPoint ?? CGPoint(x: 0.5, y: 1)
    self.layer.insertSublayer(gradient, at: 0)
  }

  func getImage() -> UIImage {
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
    defer { UIGraphicsEndImageContext() }
    layer.render(in: UIGraphicsGetCurrentContext()! )
    let image = UIGraphicsGetImageFromCurrentImageContext()
    return image!
  }
}
