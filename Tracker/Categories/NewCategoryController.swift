import UIKit

final class NewCategoryController: ModalController {
    
    // MARK: - Constants
    private enum Layout {
        static let titleText = "Новая категория"
        static let buttonText = "Готово"
        static let textFieldPlaceholderText = "Введите название категории"
        
        static let nameFieldViewTopInset: CGFloat = 38
        static let sideInset: CGFloat = 16
        static let stackBottomInset: CGFloat = 16
    }
    
    // MARK: - Layout
    
    // MARK: - UI Elements
    private lazy var nameFieldView = ValidatingTextFieldView(
        placeholder: Layout.textFieldPlaceholderText
    )
    
    private lazy var button: UIButton = {
        let button = BlackButton(title: Layout.buttonText, isInitiallyEnabled: false)
        button.addTarget(self, action: #selector(Self.didTapButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [button])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleLabel()
        setupSubViews()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    private func setupTitleLabel() {
        self.titleLabel.text = Layout.titleText
    }
    
    private func setupSubViews() {
        [nameFieldView, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        setupNameFieldViewBindings()
    }
    
    private func setupNameFieldViewBindings() {
        nameFieldView.onTextChange = { [weak self] _ in
            self?.updateButtonState()
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameFieldView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.nameFieldViewTopInset),
            nameFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.sideInset),
            nameFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.sideInset),
            
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Layout.stackBottomInset),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.sideInset),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.sideInset)
        ])
    }
    
    // MARK: - Public Properties
    
    
    // MARK: - Private Properties
    
    // MARK: - Actions
    @objc private func didTapButton(_ sender: Any) {
        
    }
    
    // MARK: - Private Methods
    private func validateName(from textField: UITextField) -> String? {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return nil }
        return text
    }
    
    private func createNewCategory(name: String) {
        
    }
    
    private func updateButtonState() {
        let isValid = nameFieldView.validatedText() != nil
        
        button.isEnabled = isValid
    }
    
}
// MARK: - Preview
#Preview("NewCategoryController") {
    NewCategoryController()
}

