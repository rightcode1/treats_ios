import UIKit

extension CALayer {
  func applySketchShadow(
    color: UIColor = .black,
    alpha: Float = 0.15,
    x: CGFloat = 0,
    y: CGFloat = 0,
    blur: CGFloat = 15,
    spread: CGFloat = 0)
  {
    shadowColor = color.cgColor
    shadowOpacity = alpha
    shadowOffset = CGSize(width: x, height: y)
    shadowRadius = blur / 2.0
    if spread == 0 {
      shadowPath = nil
    } else {
      let dx = -spread
      let rect = bounds.insetBy(dx: dx, dy: dx)
      shadowPath = UIBezierPath(rect: rect).cgPath
    }
  }

  func dismissSketchShadow(
    color: UIColor = .white,
    alpha: Float = 0,
    x: CGFloat = 0,
    y: CGFloat = 0,
    blur: CGFloat = 0,
    spread: CGFloat = 0)
  {
    shadowColor = color.cgColor
    shadowOpacity = alpha
    shadowOffset = CGSize(width: x, height: y)
    shadowRadius = 0
    if spread == 0 {
      shadowPath = nil
    } else {
      let dx = -spread
      let rect = bounds.insetBy(dx: dx, dy: dx)
      shadowPath = UIBezierPath(rect: rect).cgPath
    }
  }
}
