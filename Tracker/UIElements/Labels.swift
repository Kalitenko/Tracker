import UIKit

enum LabelStyle {
    case modalControllerTitle
    case buttonTitle
    case standard
    case subtitle
    case collectionHeader
    case bold32
    
    var font: UIFont {
        switch self {
        case .modalControllerTitle: .medium16
        case .buttonTitle: .medium16
        case .standard: .regular17
        case .subtitle: .regular17
        case .collectionHeader: .bold19
        case .bold32: .bold32
        }
    }
    
    var color: UIColor {
        switch self {
        case .modalControllerTitle: UIColor(resource: .black)
        case .buttonTitle: UIColor(resource: .white)
        case .standard: UIColor(resource: .black)
        case .subtitle: UIColor(resource: .gray)
        case .collectionHeader: UIColor(resource: .black)
        case .bold32: UIColor(resource: .black)
        }
    }
    
    var alignment: NSTextAlignment {
        switch self {
        case .modalControllerTitle: .center
        case .buttonTitle: .center
        case .standard: .left
        case .subtitle: .left
        case .collectionHeader: .left
        case .bold32: .center
        }
    }
}

final class Label: UILabel {
    
    init(text: String,
         font: UIFont,
         color: UIColor = UIColor(resource: .black),
         alignment: NSTextAlignment = .left) {
        super.init(frame: .zero)
        self.text = text
        self.font = font
        textColor = color
        textAlignment = alignment
    }
    
    init(text: String,
         style: LabelStyle) {
        super.init(frame: .zero)
        self.text = text
        self.font = style.font
        textColor = style.color
        textAlignment = style.alignment
    }
    
    init(style: LabelStyle) {
        super.init(frame: .zero)
        self.font = style.font
        textColor = style.color
        textAlignment = style.alignment
    }
    
    init(text: String,
         style: LabelStyle,
         color: UIColor? = nil,
         alignment: NSTextAlignment? = nil) {
        super.init(frame: .zero)
        self.text = text
        self.font = style.font
        textColor = color ?? style.color
        textAlignment = alignment ?? style.alignment
    }
    
    init(font: UIFont,
         color: UIColor = UIColor(resource: .black),
         alignment: NSTextAlignment = .left) {
        super.init(frame: .zero)
        self.text = text
        self.font = font
        textColor = color
        textAlignment = alignment
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
}
