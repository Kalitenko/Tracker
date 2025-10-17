import UIKit

final class ValidatingTextFieldView: UIView {
    
    // MARK: - Constants
    private enum Layout {
        static let limitSymbolsNumber = 38
        static let limitLabelText = "Ограничение \(limitSymbolsNumber) символов"
        static let textFieldHeight: CGFloat = 75
        static let sideInset: CGFloat = 16
        static let cornerRadius: CGFloat = 16
        static let labelTopInset: CGFloat = 8
    }
    
    // MARK: - UI Elements
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.regular17
        textField.textColor = UIColor(resource: .black)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Layout.sideInset, height: 0))
        textField.leftViewMode = .always
        textField.backgroundColor = UIColor(resource: .background)
        textField.layer.cornerRadius = Layout.cornerRadius
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        return textField
    }()
    
    private lazy var limitLabel: UILabel = {
        let label = Label(
            text: Layout.limitLabelText,
            style: .standard,
            color: UIColor(resource: .red),
            alignment: .center
        )
        label.isHidden = true
        
        return label
    }()
    
    // MARK: - Public Properties
    var text: String? {
        textField.text
    }
    
    var isValid: Bool {
        validateText() != nil
    }
    
    // MARK: - Callback
    var onTextChange: ((String?) -> Void)?
        
    // MARK: - Initializers
    init(placeholder: String) {
        super.init(frame: .zero)
        textField.placeholder = placeholder
        setupSubViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Setup Methods
    private func setupSubViews() {
        [textField, limitLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: Layout.textFieldHeight),
            
            limitLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: Layout.labelTopInset),
            limitLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            limitLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func textDidChange(_ textField: UITextField) {
        let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
        let tooLong = textCount > Layout.limitSymbolsNumber

        limitLabel.isHidden = !tooLong
        onTextChange?(textField.text)
    }

    // MARK: - Validation
    private func validateText() -> String? {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty,
              text.count <= Layout.limitSymbolsNumber else {
            return nil
        }
        return text
    }

    func validatedText() -> String? {
        return validateText()
    }
}
