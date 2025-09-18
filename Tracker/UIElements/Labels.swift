import UIKit

enum LabelStyle {
    case modalControllerTitle
    case buttonTitle
    case standard
    case subtitle
    
    var font: UIFont {
        switch self {
        case .modalControllerTitle: .medium16
        case .buttonTitle: .medium16
        case .standard: .regular17
        case .subtitle: .regular17
        }
    }
    
    var color: UIColor {
        switch self {
        case .modalControllerTitle: UIColor(resource: .black)
        case .buttonTitle: UIColor(resource: .white)
        case .standard: UIColor(resource: .black)
        case .subtitle: UIColor(resource: .gray)
        }
    }
    
    var alignment: NSTextAlignment {
        switch self {
        case .modalControllerTitle: .center
        case .buttonTitle: .center
        case .standard: .left
        case .subtitle: .left
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
        self.font = font
        textColor = color ?? style.color
        textAlignment = alignment ?? style.alignment
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

