import UIKit

final class CategoryListViewController: ModalController {
    
    // MARK: - Constants
    private enum Layout {
        static let titleText = "Категория"
        static let buttonText = "Добавить категорию"
        static let emptyStateLabelText = "Привычки и события можно\nобъединить по смыслу"
        static let editButtonText = "Редактировать"
        static let deleteButtonText = "Удалить"
        static let alertQuestion = "Эта категория точно не нужна?"
        
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
    private let viewModel: CategoryListViewModel
    
    // MARK: - Initializers
    init(viewModel: CategoryListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Actions
    @objc private func didTapButton(_ sender: Any) {
        let vc = CategoryController(mode: .create)
        
        present(vc, animated: true)
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
        
        viewModel.onCategoriesChangedWithChanges = { [weak self] data in
            guard let self = self else { return }
            let (categories, changes) = data
            self.options = categories
            self.applyTableChanges(changes)
        }
    }
    
    private func applyTableChanges(_ changes: [DataChange]) {
        optionsTableView.performBatchUpdates({
            for change in changes {
                switch change {
                case .insert(let indexPath):
                    optionsTableView.insertRows(at: [indexPath], with: .automatic)
                case .delete(let indexPath):
                    optionsTableView.deleteRows(at: [indexPath], with: .automatic)
                    if indexPath == selectedIndexPath {
                        self.selectedIndexPath = nil
                    }
                case .update(let indexPath):
                    optionsTableView.reloadRows(at: [indexPath], with: .automatic)
                case .move(let from, let to):
                    optionsTableView.moveRow(at: from, to: to)
                default:
                    break
                }
            }
        }, completion: { [weak self] _ in
            self?.updateTableHeight()
            self?.updateSelectionState()
            self?.updateLastItem()
        })
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
    
    private func updateSelectionState() {
        guard let selectedIndexPath = selectedIndexPath else { return }
        
        for visibleCell in optionsTableView.visibleCells {
            guard let indexPath = optionsTableView.indexPath(for: visibleCell),
                  let checkmarkCell = visibleCell as? CheckmarkCell else { continue }
            let isSelected = indexPath == selectedIndexPath
            checkmarkCell.setChecked(isSelected)
        }
    }
    
    private func updateLastItem() {
        if let lastVisible = optionsTableView.indexPathsForVisibleRows?.last {
            optionsTableView.reloadRows(at: [lastVisible], with: .none)
        }
    }
    
}

// MARK: - UITableViewDataSource
extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = optionsTableView.dequeueReusableCell(withIdentifier: tableStyle.reuseIdentifier, for: indexPath)
        let isLastElement = indexPath.row == options.count - 1
        
        if let checkmarkCell = cell as? CheckmarkCell {
            let categoryName = options[indexPath.row].title
            checkmarkCell.configure(title: categoryName, isLastElement: isLastElement)
            if categoryName == selectedCategory?.title {
                selectedIndexPath = indexPath
            }
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
        if let previousIndexPath = selectedIndexPath,
           let previousCell = tableView.cellForRow(at: previousIndexPath) as? CheckmarkCell {
            previousCell.setChecked(false)
        }
        
        if let currentCell = tableView.cellForRow(at: indexPath) as? CheckmarkCell {
            currentCell.setChecked(true)
        }
        
        selectedIndexPath = indexPath
        selectedCategory = options[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let category = selectedCategory {
            onCategorySelected?(category)
        }
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let category = options[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: Layout.editButtonText) { [weak self] _ in
                self?.editCategory(category)
            }
            
            let deleteAction = UIAction(title: Layout.deleteButtonText, attributes: .destructive) { [weak self] _ in
                self?.showDeleteAlert(for: category)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    private func editCategory(_ category: TrackerCategory) {
        let vc = CategoryController(mode: .edit(category))
        present(vc, animated: true)
    }
    
    private func showDeleteAlert(for category: TrackerCategory) {
        AlertHelper.showDeleteConfirmation(
            from: self,
            message: Layout.alertQuestion
        ) { [weak self] in
            self?.viewModel.deleteCategory(category)
        }
    }
}


// MARK: - Preview
#Preview("CategoryController") {
    let viewModel = CategoryListViewModel()
    let vc = CategoryListViewController(viewModel: viewModel)
    
    return vc
}
