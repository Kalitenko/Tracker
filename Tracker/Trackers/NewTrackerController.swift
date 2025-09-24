import UIKit

protocol NewTrackerDelegate: AnyObject {
    func didCreateNewTracker(tracker: Tracker, categoryTitle: String)
}

enum TrackerType {
    case habit
    case irregular
    
    var titleText: String {
        switch self {
        case .habit: return "Новая привычка"
        case .irregular: return "Новое нерегулярное событие"
        }
    }
    
    var options: [String] {
        switch self {
        case .habit: return ["Категория", "Расписание"]
        case .irregular: return ["Категория"]
        }
    }
}

final class NewTrackerController: ModalController {
    
    // MARK: - Public Properties
    weak var delegate: NewTrackerDelegate?
    
    // MARK: - Private Properties
    private let trackerType: TrackerType
    private let tableStyle: TableStyle = .arrow
    private var selectedDays: [Day] = []
    private var selectedCategory: String?
    private var defaultCategory = "Важное"
    private var currentId: UInt = UInt.random(in: 1...100_000)
    private var selectedColor: UIColor?
    private var selectedEmoji: String?
    
    // MARK: - Init
    init(trackerType: TrackerType) {
        self.trackerType = trackerType
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Constants
    private enum Layout {
        // Texts
        static let textFieldPlaceholderText = "Введите название трекера"
        static let limitLabelText = "Ограничение \(limitSymbolsNumber) символов"
        static let cancelButtonText = "Отменить"
        static let createButtonText = "Создать"
        
        // Limits
        static let limitSymbolsNumber = 38
        
        // Sizes
        static let cellHeight: CGFloat = 75
        static let textFieldHeight: CGFloat = 75
        static let cornerRadius: CGFloat = 16
        
        // Insets / Spacing
        static let titleTopInset: CGFloat = 27
        static let textFieldTopInset: CGFloat = 24
        static let limitLabelTopInset: CGFloat = 8
        static let optionsTableTopInset: CGFloat = 24
        static let sideInset: CGFloat = 16
        static let buttonsStackSideInset: CGFloat = 20
        static let buttonsStackSpacing: CGFloat = 8
    }
    
    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Layout.textFieldPlaceholderText
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
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.spacing = Layout.buttonsStackSpacing
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var optionsTableView: Table = {
        let table = Table(style: tableStyle)
        table.delegate = self
        table.dataSource = self
        table.separatorInset = UIEdgeInsets(top: 0, left: Layout.sideInset, bottom: 0, right: Layout.sideInset)
        table.tableFooterView = UIView()
        return table
    }()
    
    private lazy var emojiHandler = EmojiCollectionHandler { emoji in
        Logger.debug("Выбран эмоджи: \(emoji)")
        self.selectedEmoji = emoji
    }
    
    private lazy var colorHandler = ColorCollectionHandler { color in
        Logger.debug("Выбран цвет: \(color)")
        self.selectedColor = color
    }
    
    private lazy var emojiCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: EmojiCollectionHandler.makeLayout()
        )
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: String(describing: EmojiCell.self))
        collectionView.register(CollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeaderView.identifier)
        
        collectionView.dataSource = emojiHandler
        collectionView.delegate = emojiHandler
        
        return collectionView
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: ColorCollectionHandler.makeLayout()
        )
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: String(describing: ColorCell.self))
        collectionView.register(CollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeaderView.identifier)
        
        collectionView.dataSource = colorHandler
        collectionView.delegate = colorHandler
        
        return collectionView
    }()
    
    private lazy var collectionsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emojiCollectionView, colorCollectionView])
        stackView.axis = .vertical
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
        self.titleLabel.text = trackerType.titleText
    }
    
    private func setupSubViews() {
        [nameTextField, limitLabel, optionsTableView, collectionsStackView].forEach {
            contentView.addSubview($0)
        }
        scrollView.addSubview(contentView)
        
        [scrollView, buttonsStackView].forEach {
            view.addSubview($0)
        }
        
        [scrollView, contentView, titleLabel, nameTextField, limitLabel, buttonsStackView, optionsTableView, collectionsStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            buttonsStackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.buttonsStackSideInset),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.buttonsStackSideInset),
            
            nameTextField.heightAnchor.constraint(equalToConstant: Layout.textFieldHeight),
            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.textFieldTopInset),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.sideInset),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.sideInset),
            
            limitLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: Layout.limitLabelTopInset),
            limitLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            optionsTableView.topAnchor.constraint(equalTo: limitLabel.bottomAnchor, constant: Layout.optionsTableTopInset),
            optionsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.sideInset),
            optionsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.sideInset),
            optionsTableView.heightAnchor.constraint(equalToConstant: CGFloat(trackerType.options.count) * Layout.cellHeight),
            
            collectionsStackView.topAnchor.constraint(equalTo: optionsTableView.bottomAnchor, constant: 32),
            collectionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            collectionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            collectionsStackView.heightAnchor.constraint(equalToConstant: 224 * 2),
            
            collectionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    
    
    // MARK: - Private Methods
    private func validateName(from textField: UITextField) -> String? {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return nil }
        return text
    }
    
    private func createNewTracker(name: String, category: String, schedule: [Day]) {
        let id = currentId
        guard let emoji = selectedEmoji, let color = selectedColor else {
            Logger.error("Emoji или цвет не выбраны")
            return
        }
        let tracker = Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
        delegate?.didCreateNewTracker(tracker: tracker, categoryTitle: category)
    }
    
    // MARK: - Actions
    @objc private func didTapCancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreateButton(_ sender: Any) {
        guard let name = validateName(from: nameTextField),
              let category = selectedCategory else { return }
        
        if trackerType == .habit && selectedDays.isEmpty { return }
        
        let schedule = trackerType == .habit ? selectedDays : Day.allCases
        createNewTracker(name: name, category: category, schedule: schedule)
        dismiss(animated: true)
    }
    
    @objc private func textDidChange(_ textField: UITextField) {
        limitLabel.isHidden = (textField.text?.count ?? 0) <= Layout.limitSymbolsNumber
    }
}

// MARK: - UITableViewDataSource
extension NewTrackerController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        trackerType.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = optionsTableView.dequeueReusableCell(
            withIdentifier: tableStyle.reuseIdentifier,
            for: indexPath
        )
        
        let isLastElement = indexPath.isLastRow(in: tableView)
        
        if let arrowCell = cell as? ArrowCell {
            arrowCell.configure(title: trackerType.options[indexPath.row], subtitle: nil, isLastElement: isLastElement)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NewTrackerController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Layout.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let option = trackerType.options[indexPath.row]
        let isLastElement = indexPath.isLastRow(in: tableView)
        if option == "Категория" {
            selectedCategory = defaultCategory
            if let cell = tableView.cellForRow(at: indexPath) as? TableCell {
                cell.configure(title: option, subtitle: selectedCategory, isLastElement: isLastElement)
            }
        } else if option == "Расписание" {
            let vc = ScheduleController()
            vc.selectedDays = selectedDays
            vc.onDaysSelected = { [weak self] days in
                self?.selectedDays = days
                if let cell = tableView.cellForRow(at: indexPath) as? TableCell {
                    cell.configure(title: option, subtitle: days.displayText, isLastElement: isLastElement)
                }
            }
            present(vc, animated: true)
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview("New Habit Controller") {
    NewTrackerController(trackerType: .habit)
}

#Preview("New Irregular Event Controller") {
    NewTrackerController(trackerType: .irregular)
}
#endif
