import UIKit

final class CategoryController: ModalController {
    
    // MARK: - Constants
    private enum Layout {
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
        bindViewModel()
    }
    
    // MARK: - Setup Methods
    private func setupTitleLabel() {
        self.titleLabel.text = mode.title
    }
    
    private func setupSubViews() {
        [nameFieldView, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        setupNameFieldViewBindings()
    }
    
    private func setupNameFieldViewBindings() {
        nameFieldView.onTextChange = { [weak self] text in
            self?.viewModel.didChangeName(text ?? "")
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
    
    private func bindViewModel() {
        viewModel.onValidationChanged = { [weak self] isEnabled in
            self?.button.isEnabled = isEnabled
        }
        
        viewModel.onValidationError = { [weak self] error in
            guard let self else { return }
            if let error = error {
                self.nameFieldView.showError(message: error)
            } else {
                self.nameFieldView.hideError()
            }
        }
        
    }
    
    // MARK: - Public Properties
    
    // MARK: - Private Properties
    private let mode: Mode
    private let viewModel: CategoryViewModel
    
    // MARK: - Initializers
    init(mode: Mode) {
        self.mode = mode
        self.viewModel = .init(mode: mode)
        super.init(nibName: nil, bundle: nil)
        switch mode {
        case .edit(let category):
            title = category.title
            nameFieldView.setText(category.title)
        default:
            break
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Actions
    @objc private func didTapButton(_ sender: Any) {
        viewModel.didTapButton()
        dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    private func validateName(from textField: UITextField) -> String? {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return nil }
        return text
    }
    
}
// MARK: - Preview
#Preview("NewCategoryController") {
    CategoryController(mode: .create)
}
#Preview("NewCategoryController") {
    CategoryController(mode: .edit(TrackerCategory(title: "Test", trackers: [])))
}

