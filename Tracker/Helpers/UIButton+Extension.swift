import UIKit

extension UIButton {
    func applyStyle() {
        layer.cornerRadius = 16
        titleLabel?.font = UIFont.medium16
        clipsToBounds = true
    }
}
