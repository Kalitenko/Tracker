import UIKit

protocol NewHabitDelegate: AnyObject {
    func didCreateNewHabit(tracker: Tracker, categoryTitle: String)
}

final class NewHabitController: ModalController {
    
    // MARK: - Constants
    private enum Layout {
        static let titleText = "Новая привычка"
        static let textFieldPlaceholderText = "Введите название трекера"
        static let limitSymbolsNumber = 38
        static let limitLabelText = "Ограничение \(Layout.limitSymbolsNumber) символов"
        static let cancelButtonText = "Отменить"
        static let createButtonText = "Создать"
        static let cellHeight: CGFloat = 75
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
        button.addTarget(self, action: #selector(Self.didTapCancelButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = BlackButton(title: Layout.createButtonText)
        button.addTarget(self, action: #selector(Self.didTapCreateButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private lazy var optionsTableView: Table = {
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
        [titleLabel, nameTextField, limitLabel, stackView, optionsTableView].forEach {
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
            
            optionsTableView.topAnchor.constraint(equalTo: limitLabel.bottomAnchor, constant: 24),
            optionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            optionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            optionsTableView.heightAnchor.constraint(equalToConstant: CGFloat(options.count) * Layout.cellHeight)
            
        ])
    }
    
    
    // MARK: - Public Properties
    var delegate: NewHabitDelegate?
    
    // MARK: - Private Properties
    private let options: [String] = ["Категория", "Расписание"]
    private let tableStyle: TableStyle = .arrow
    private var selectedDays: [Day] = []
    private var selectedCategory: String?
    private var defaultCategory = "Важное"
    private var currentId: UInt = 1
    
    // MARK: - Private Methods
    private func validateName(from textField: UITextField) -> String? {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            return nil
        }
        return text
    }
    
    private func createNewTracker(name: String, category: String, schedule: [Day]) {
        let id = currentId
        let emoji = "🩼"
        let color = UIColor.random()
        
        let tracker = Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
        currentId += 1
        
        delegate?.didCreateNewHabit(tracker: tracker, categoryTitle: category)
    }
    
    // MARK: - Actions
    @objc private func didTapCancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreateButton(_ sender: Any) {
        Logger.info("Попытка создания нового трекера")
        guard let name = validateName(from: nameTextField),
              let category = selectedCategory,
              !selectedDays.isEmpty else {return}
        
        createNewTracker(name: name, category: category, schedule: selectedDays)
        
        dismiss(animated: true)
    }
    
    @objc private func textDidChange(_ textField: UITextField) {
        let shouldShowWarning = (textField.text?.count ?? 0) > Layout.limitSymbolsNumber
        limitLabel.isHidden = !shouldShowWarning
    }
    
}

// MARK: - UITableViewDataSource
extension NewHabitController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = optionsTableView.dequeueReusableCell(withIdentifier: tableStyle.reuseIdentifier, for: indexPath)
        if let arrowCell = cell as? ArrowCell {
            arrowCell.configure(title: options[indexPath.row], subtitle: nil)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
}

// MARK: - UITableViewDataSource
extension NewHabitController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Layout.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let option = options[indexPath.row]
        if indexPath.row == 0 {
            selectedCategory = defaultCategory
            Logger.info("Выбрана категория: \(selectedCategory)")
            if let cell = tableView.cellForRow(at: indexPath) as? TableCell {
                cell.configure(title: option, subtitle: selectedCategory)
            }
        } else {
            let vc = ScheduleController()
            vc.selectedDays = selectedDays
            vc.onDaysSelected = { [weak self] days in
                self?.selectedDays = days
                let daysText = days.displayText
                if let cell = tableView.cellForRow(at: indexPath) as? TableCell {
                    cell.configure(title: option, subtitle: daysText)
                }
                Logger.info("Выбраны дни: \(daysText)")
            }
            present(vc, animated: true)
        }
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
