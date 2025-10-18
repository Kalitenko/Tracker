import UIKit

final class CategoryListViewController: ModalController {
    
    // MARK: - Constants
    private enum Layout {
        static let titleText = "Категория"
        static let buttonText = "Добавить категорию"
        static let emptyStateLabelText = "Привычки и события можно\nобъединить по смыслу"
        
        static let cellHeight: CGFloat = 75
        static let titleTopInset: CGFloat = 27
        static let tableTopInset: CGFloat = 38
        static let tableSideInset: CGFloat = 16
        static let stackSideInset: CGFloat = 20
        static let stackBottomInset: CGFloat = 16
        static let tableToStackSpacing: CGFloat = 24
        static let emptyStateViewHorizontalInset: CGFloat = 16
        static let emptyStateViewHalfSize: CGFloat = 62
    }
    
    // MARK: - Layout
    
    // MARK: - UI Elements
    private lazy var optionsTableView: Table = {
        let table = Table(style: tableStyle)
        table.delegate = self
        table.dataSource = self
        
        return table
    }()
    
    private lazy var button: UIButton = {
        let button = BlackButton(title: Layout.buttonText)
        button.addTarget(self, action: #selector(Self.didTapButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [button])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private lazy var emptyStateView = EmptyStateView(text: Layout.emptyStateLabelText)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleLabel()
        setupSubViews()
        setupConstraints()
        bindViewModel()
        viewModel.loadCategories()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeight()
    }
    
    // MARK: - Setup Methods
    private func setupTitleLabel() {
        self.titleLabel.text = Layout.titleText
    }
    
    private func setupSubViews() {
        [optionsTableView, stackView, emptyStateView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        let guide = view.safeAreaLayoutGuide
        
        let tableHeightConstraint = optionsTableView.heightAnchor.constraint(equalToConstant: 0)
        self.tableHeightConstraint = tableHeightConstraint
        
        let middleGuide = UILayoutGuide()
        view.addLayoutGuide(middleGuide)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: Layout.titleTopInset),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableHeightConstraint,
            optionsTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.tableTopInset),
            optionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.tableSideInset),
            optionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.tableSideInset),
            optionsTableView.bottomAnchor.constraint(lessThanOrEqualTo: stackView.topAnchor, constant: -Layout.tableToStackSpacing),
            
            stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -Layout.stackBottomInset),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.stackSideInset),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.stackSideInset),
            
            middleGuide.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            middleGuide.bottomAnchor.constraint(equalTo: stackView.topAnchor),
            
            emptyStateView.centerYAnchor.constraint(equalTo: middleGuide.centerYAnchor, constant: -Layout.emptyStateViewHalfSize),
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.emptyStateViewHorizontalInset),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.emptyStateViewHorizontalInset)
        ])
    }
    
    // MARK: - Public Properties
    var onCategorySelected: ((TrackerCategory) -> Void)?
    var selectedCategory: TrackerCategory?
    
    // MARK: - Private Properties
    private var options: [TrackerCategory] = []
    private let tableStyle: TableStyle = .checkmark
    private var tableHeightConstraint: NSLayoutConstraint?
    private var selectedIndexPath: IndexPath?
    private let viewModel = CategoryListViewModel()
    
    
    // MARK: - Actions
    @objc private func didTapButton(_ sender: Any) {
            guard let category = selectedCategory else { return }
            dismiss(animated: true) { [weak self] in
                self?.onCategorySelected?(category)
            }
        }
    
    // MARK: - Private Methods
    private func bindViewModel() {
            viewModel.onCategoriesChanged = { [weak self] categories in
                self?.options = categories
                self?.optionsTableView.reloadData()
                self?.updateTableHeight()
            }
            
            viewModel.onEmptyStateChanged = { [weak self] isEmpty in
                isEmpty ? self?.emptyStateView.show() : self?.emptyStateView.hide()
            }
            
            viewModel.onSelectionChanged = { [weak self] category in
                self?.selectedCategory = category
            }
        }
    
    private func updateTableHeight() {
        optionsTableView.layoutIfNeeded()
        
        guard let tableHeightConstraint else { return }
        
        let contentHeight = CGFloat(options.count) * Layout.cellHeight
        let tableTop = optionsTableView.frame.minY
        let stackTop = stackView.frame.minY
        let availableHeight = stackTop - tableTop - Layout.tableToStackSpacing
        
        tableHeightConstraint.constant = min(contentHeight, availableHeight)
        optionsTableView.isScrollEnabled = contentHeight > availableHeight
    }
}

// MARK: - UITableViewDataSource
extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Logger.debug("\(options.count)")
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = optionsTableView.dequeueReusableCell(withIdentifier: tableStyle.reuseIdentifier, for: indexPath)
        let isLastElement = indexPath.row == options.count - 1
        
        if let checkmarkCell = cell as? CheckmarkCell {
            let categoryName = options[indexPath.row].title
            checkmarkCell.configure(title: categoryName, isLastElement: isLastElement)
            let isSelected = indexPath == selectedIndexPath
            checkmarkCell.setChecked(isSelected)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Layout.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        selectedCategory = options[indexPath.row]
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Preview
#Preview("CategoryController") {
    let vc = CategoryListViewController()
    
    return vc
}
