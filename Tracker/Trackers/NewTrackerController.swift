import UIKit

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
    
    private lazy var emojiHandler = EmojiCollectionHandler { [weak viewModel] emoji in
        viewModel?.selectEmoji(emoji)
    }
    
    private lazy var colorHandler = ColorCollectionHandler { [weak viewModel] color in
        viewModel?.selectColor(color)
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
        bindViewModel()
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
            self?.viewModel.didChangeName(text ?? "")
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
            optionsTableView.heightAnchor.constraint(equalToConstant: CGFloat(options.count) * Layout.cellHeight),
            
            collectionsStackView.topAnchor.constraint(equalTo: optionsTableView.bottomAnchor, constant: 32),
            collectionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            collectionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            collectionsStackView.heightAnchor.constraint(equalToConstant: 224 * 2),
            
            collectionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onValidationError = { [weak self] error in
            guard let self else { return }
            if let error = error {
                self.nameFieldView.showError(message: error)
            } else {
                self.nameFieldView.hideError()
            }
        }
        
        viewModel.onValidationChanged = { [weak self] isEnabled in
            self?.createButton.isEnabled = isEnabled
        }
        
        viewModel.onCategoryChanged = { [weak self] category in
            self?.selectedCategory = category
        }
        
        viewModel.onScheduleChanged = { [weak self] schedule in
            self?.selectedDays = schedule
        }
    }
    
    // MARK: - Private Properties
    private let trackerType: TrackerType
    private let tableStyle: TableStyle = .arrow
    private var selectedCategory: TrackerCategory?
    private var selectedDays: [WeekDay] = []
    private let viewModel: NewTrackerViewModel
    private var options: [String] {
        viewModel.options
    }
    
    // MARK: - Initializers
    init(trackerType: TrackerType) {
        self.trackerType = trackerType
        self.viewModel = .init(trackerType: trackerType, category: selectedCategory, schedule: selectedDays)
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
        viewModel.createTracker()
        var root = presentingViewController
        while let parent = root?.presentingViewController {
            root = parent
        }
        root?.dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension NewTrackerController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = optionsTableView.dequeueReusableCell(
            withIdentifier: tableStyle.reuseIdentifier,
            for: indexPath
        )
        
        let isLastElement = indexPath.isLastRow(in: tableView)
        
        if let arrowCell = cell as? ArrowCell {
            arrowCell.configure(title: options[indexPath.row], subtitle: nil, isLastElement: isLastElement)
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
        let option = options[indexPath.row]
        let isLastElement = indexPath.isLastRow(in: tableView)
        if option == "Категория" {
            let vc = CategoryListViewController()
            vc.selectedCategory = selectedCategory
            vc.onCategorySelected = { [weak self] category in
                self?.viewModel.selectCategory(category)
                if let cell = tableView.cellForRow(at: indexPath) as? TableCell {
                    cell.configure(title: option, subtitle: category.title, isLastElement: isLastElement)
                }
            }
            present(vc, animated: true)
        } else if option == "Расписание" {
            let vc = ScheduleController()
            vc.selectedDays = selectedDays
            vc.onDaysSelected = { [weak self] days in
                self?.viewModel.selectDays(days)
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
