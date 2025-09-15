import UIKit

final class NewHabitController: ModalController {
    
    // MARK: - Constants
    private enum Layout {
        static let titleText = "Новая привычка"
        static let textFieldPlaceholderText = "Введите название трекера"
        static let limitSymbolsNumber = 38
        static let limitLabelText = "Ограничение \(Layout.limitSymbolsNumber) символов"
        static let cancelButtonText = "Отменить"
        static let createButtonText = "Создать"
    }
    
    // MARK: - Layout
    
    // MARK: - UI Elements
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Layout.textFieldPlaceholderText
        textField.font = UIFont.regular17
        textField.textColor = UIColor(resource: .black)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.backgroundColor = UIColor(resource: .background)
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        
        return textField
    }()
    
    private lazy var limitLabel: UILabel = {
        let label = Label(text: Layout.limitLabelText, style: .standard,
                          color:  UIColor(resource: .red), alignment: .center)
        label.isHidden = true
        
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = OutlineRedButton(title: Layout.cancelButtonText)
        button.addTarget(self, action: #selector(Self.didTapAddTrackerButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = BlackButton(title: Layout.createButtonText)
        button.addTarget(self, action: #selector(Self.didTapAddTrackerButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private lazy var settingsTableView: Table = {
        let table = Table(style: tableStyle)
        table.delegate = self
        table.dataSource = self
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.tableFooterView = UIView()
        
        return table
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
        [titleLabel, nameTextField, limitLabel, stackView, settingsTableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            limitLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            limitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            settingsTableView.topAnchor.constraint(equalTo: limitLabel.bottomAnchor, constant: 24),
            settingsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            settingsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            settingsTableView.heightAnchor.constraint(equalToConstant: CGFloat(settings.count * 75))
            
        ])
    }
    
    
    // MARK: - Public Properties
    
    
    // MARK: - Private Properties
    private let settings: [String] = ["Категория", "Расписание"]
    private let tableStyle: TableStyle = .arrow
    
    
    // MARK: - Private Methods
    
    // MARK: - Actions
    @objc private func didTapAddTrackerButton(_ sender: Any) {
        Logger.info("didTapAddTrackerButton was clicked")
    }
    
    @objc private func textDidChange(_ textField: UITextField) {
        let shouldShowWarning = (textField.text?.count ?? 0) > Layout.limitSymbolsNumber
        limitLabel.isHidden = !shouldShowWarning
    }
    
}

// MARK: - UITableViewDataSource
extension NewHabitController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = settingsTableView.dequeueReusableCell(withIdentifier: tableStyle.reuseIdentifier, for: indexPath)
        if let arrowCell = cell as? ArrowCell {
            arrowCell.configure(title: settings[indexPath.row], subtitle: nil)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
}

// MARK: - UITableViewDataSource
extension NewHabitController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

// MARK: - Preview
#if DEBUG
extension NewHabitController {
    
}
#endif

#Preview("Only New Habit Controller") {
    let vc = NewHabitController()
    
    return vc
}
