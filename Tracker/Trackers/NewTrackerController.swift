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
    
    // MARK: - Constants
    private enum Layout {
        // Texts
        static let textFieldPlaceholderText = "Введите название трекера"
        static let cancelButtonText = "Отменить"
        static let createButtonText = "Создать"
        
        // Sizes
        static let cellHeight: CGFloat = 75
        static let textFieldHeight: CGFloat = 75
        static let cornerRadius: CGFloat = 16
        
        // Insets / Spacing
        static let nameFieldViewTopInset: CGFloat = 24
        static let optionsTableTopInset: CGFloat = 24
        static let sideInset: CGFloat = 16
        static let buttonsStackSideInset: CGFloat = 20
        static let buttonsStackSpacing: CGFloat = 8
        
        // ValidatingTextFieldView
        static let limitSymbolsNumber = 38
        static let limitLabelText = "Ограничение \(limitSymbolsNumber) символов"
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
    
    private lazy var nameFieldView = ValidatingTextFieldView(
        placeholder: Layout.textFieldPlaceholderText
    )
    
    private lazy var cancelButton: UIButton = {
        let button = OutlineRedButton(title: Layout.cancelButtonText)
        button.addTarget(self, action: #selector(Self.didTapCancelButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = BlackButton(title: Layout.createButtonText, isInitiallyEnabled: false)
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
        [nameFieldView, optionsTableView, collectionsStackView].forEach {
            contentView.addSubview($0)
        }
        scrollView.addSubview(contentView)
        
        [scrollView, buttonsStackView].forEach {
            view.addSubview($0)
        }
        
        [scrollView, contentView, titleLabel, nameFieldView, buttonsStackView, optionsTableView, collectionsStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupNameFieldViewBindings()
    }
    
    private func setupNameFieldViewBindings() {
        nameFieldView.onTextChange = { [weak self] text in
            guard let self = self else { return }
            self.trackerName = text?.trimmingCharacters(in: .whitespacesAndNewlines)
            self.validateText()
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
            
            nameFieldView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.nameFieldViewTopInset),
            nameFieldView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.sideInset),
            nameFieldView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.sideInset),
            
            optionsTableView.topAnchor.constraint(equalTo: nameFieldView.bottomAnchor, constant: Layout.optionsTableTopInset),
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
    
    // MARK: - Public Properties
    weak var delegate: NewTrackerDelegate?
    
    // MARK: - Private Properties
    private let trackerType: TrackerType
    private let tableStyle: TableStyle = .arrow
    private var selectedCategory: TrackerCategory? {
        didSet { updateCreateButtonState() }
    }
    private var selectedEmoji: String? {
        didSet { updateCreateButtonState() }
    }
    private var selectedColor: UIColor? {
        didSet { updateCreateButtonState() }
    }
    private var selectedDays: [WeekDay] = [] {
        didSet { updateCreateButtonState() }
    }
    private var isNameValid: Bool = false {
        didSet { updateCreateButtonState() }
    }
    private var trackerName: String?
    private let dataProvider: DataProviderProtocol = DataProvider.shared
    
    // MARK: - Initializers
    init(trackerType: TrackerType) {
        self.trackerType = trackerType
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Actions
    @objc private func didTapCancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreateButton(_ sender: Any) {
        guard let name = trackerName,
              let title = selectedCategory?.title else { return }
        
        if trackerType == .habit && selectedDays.isEmpty { return }
        
        let schedule = trackerType == .habit ? selectedDays : WeekDay.allCases
        createNewTracker(name: name, title: title, schedule: schedule)
        dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    private func validateName(from textField: UITextField) -> String? {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return nil }
        return text
    }
    
    private func createNewTracker(name: String, title: String, schedule: [WeekDay]) {
        guard let emoji = selectedEmoji, let color = selectedColor else {
            Logger.error("Emoji или цвет не выбраны")
            return
        }
        let tracker = Tracker(name: name, color: color, emoji: emoji, schedule: schedule)
        dataProvider.createTracker(tracker, to: title)
        delegate?.didCreateNewTracker(tracker: tracker, categoryTitle: title)
    }
    
    private func updateCreateButtonState() {
        let isValid = isNameValid &&
        selectedCategory != nil &&
        selectedEmoji != nil &&
        selectedColor != nil &&
        !(trackerType == .habit && selectedDays.isEmpty)
        
        createButton.isEnabled = isValid
    }
    
    private func validateText() {
        guard let trimmed = trackerName?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
            nameFieldView.hideError()
            isNameValid = false
            return
        }
        
        if trimmed.count > Layout.limitSymbolsNumber {
            nameFieldView.showError(message: Layout.limitLabelText)
            isNameValid = false
        } else {
            nameFieldView.hideError()
            isNameValid = true
        }
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
            let vc = CategoryListViewController()
            vc.selectedCategory = selectedCategory
            vc.onCategorySelected = { [weak self] category in
                self?.selectedCategory = category
                if let cell = tableView.cellForRow(at: indexPath) as? TableCell {
                    cell.configure(title: option, subtitle: category.title, isLastElement: isLastElement)
                }
            }
            present(vc, animated: true)
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
