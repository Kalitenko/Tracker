import UIKit

class Button: UIButton {
    
    init(title: String,
         backgroundColor: UIColor,
         textColor: UIColor) {
        super.init(frame: .zero)
        setupTitleAndStyle(title: title, color: textColor)
        self.backgroundColor = backgroundColor
    }
    
    init(title: String, outlineColor: UIColor) {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        layer.borderWidth = 1
        layer.borderColor = outlineColor.cgColor
        setupTitleAndStyle(title: title, color: outlineColor)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setupTitleAndStyle(title: String, color: UIColor) {
        setTitle(title, for: .normal)
        setTitleColor(color, for: .normal)
        setupStyle()
    }
    
    private func setupStyle() {
        titleLabel?.font = UIFont.medium16
        titleLabel?.textAlignment = .center
        layer.cornerRadius = 16
        clipsToBounds = true
        heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
}

final class BlackButton: Button {
    
    override var isEnabled: Bool {
        didSet {
            updateState()
        }
    }
    
    private let enabledColor = UIColor(resource: .black)
    private let disabledColor = UIColor(resource: .gray)
    
    init(title: String, isInitiallyEnabled: Bool = true) {
        super.init(title: title,
                   backgroundColor: enabledColor,
                   textColor: UIColor(resource: .white))
        isEnabled = isInitiallyEnabled
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    private func updateState() {
        backgroundColor = isEnabled ? enabledColor : disabledColor
    }
}

final class OutlineRedButton: Button {
    init(title: String) {
        super.init(title: title,
                   outlineColor: UIColor(resource: .red))
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
}

final class BlueButton: Button {
    init(title: String) {
        super.init(title: title,
                   backgroundColor: UIColor(resource: .blue),
                   textColor: UIColor(resource: .ypWhite))
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
}
