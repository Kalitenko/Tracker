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
}
