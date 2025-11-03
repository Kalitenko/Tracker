import UIKit

extension UIView {
    func superview<T: UIView>(of type: T.Type) -> T? {
        var v = self.superview
        while v != nil {
            if let typed = v as? T { return typed }
            v = v?.superview
        }
        return nil
    }
    
    func applyGradientBorder(colors: [UIColor], lineWidth: CGFloat = 1, cornerRadius: CGFloat = 16) {
        layer.sublayers?.removeAll(where: { $0.name == "gradientBorder" })
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "gradientBorder"
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.5)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = lineWidth
        shapeLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2),
            cornerRadius: cornerRadius
        ).cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        
        gradientLayer.mask = shapeLayer
        
        layer.addSublayer(gradientLayer)
    }
}
