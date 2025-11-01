import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Constants
    private enum Layout {
        static let trackersLabelText = L10n.trackers
        static let searchBarText = L10n.search
        static let editButtonText = L10n.edit
        static let deleteButtonText = L10n.delete
        static let alertTrackerQuestion = "Уверены что хотите удалить трекер?"
        static let filtersButtonText = "Фильтры"
        
        static let collectionViewTopInset: CGFloat = 24
        static let emptyStateViewTopInset: CGFloat = 220
        static let emptyStateViewHorizontalInset: CGFloat = 16
        static let filtersButtonsHorizontalInset: CGFloat = 130
        static let filtersButtonsBottomInset: CGFloat = 16
    }
    
    // MARK: - Layout
    
    // MARK: - UI Elements
    private lazy var addTrackerButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(resource: .addTracker), for: .normal)
        button.addTarget(self, action: #selector(Self.didTapAddTrackerButton), for: .touchUpInside)
        button.tintColor = UIColor(resource: .black)
        
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        return datePicker
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = Layout.searchBarText
        searchController.searchBar.backgroundImage = UIImage()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        
        return searchController
    }()
    
    private lazy var uiNavigationBarAppearance: UINavigationBarAppearance = {
        let appearance = UINavigationBarAppearance()
        
        let textColor = UIColor(resource: .black)
        let font = UIFont.bold34
        
        appearance.titleTextAttributes = [
            .foregroundColor: textColor,
            .font: font
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: textColor,
            .font: font
        ]
        
        appearance.shadowColor = .clear
        appearance.backgroundColor = UIColor(resource: .white)
        
        return appearance
    }()
    
    private lazy var emptyStateView = EmptyStateView()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.backgroundColor = .clear
        
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        collectionView.register(CollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeaderView.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    private lazy var filtersButton: BlueButton = {
        let button = BlueButton(title: Layout.filtersButtonText)
        button.addTarget(self, action: #selector(Self.didTapFiltersButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubViews()
        setupConstraints()
        configureUINavigationBar()
        
        bindViewModel()
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let buttonHeight = filtersButton.frame.height
        
        collectionView.contentInset.bottom = view.safeAreaInsets.bottom + buttonHeight + Layout.filtersButtonsBottomInset
        collectionView.verticalScrollIndicatorInsets.bottom = collectionView.contentInset.bottom
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = UIColor(resource: .white)
    }
    
    private func setupSubViews() {
        [emptyStateView, collectionView, filtersButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        view.bringSubviewToFront(emptyStateView)
        view.bringSubviewToFront(filtersButton)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = Layout.trackersLabelText
    }
    
    private func setupConstraints() {
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: guide.topAnchor, constant: Layout.emptyStateViewTopInset),
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.emptyStateViewHorizontalInset),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.emptyStateViewHorizontalInset),
            
            collectionView.topAnchor.constraint(equalTo: guide.topAnchor, constant: Layout.collectionViewTopInset),
            collectionView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            filtersButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.filtersButtonsHorizontalInset),
            filtersButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.filtersButtonsHorizontalInset),
            filtersButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -Layout.filtersButtonsBottomInset)
        ])
    }
    
    private func configureUINavigationBar() {
        navigationItem.title = Layout.trackersLabelText
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        let appearance = uiNavigationBarAppearance
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func bindViewModel() {
        viewModel.onVisibleCategoriesChanged = { [weak self] visibleCategories in
            self?.visibleCategories = visibleCategories
            self?.collectionView.reloadData()
        }
        
        viewModel.onEmptyStateChanged = { [weak self] emptyStateViewType in
            guard let type = emptyStateViewType else {
                self?.emptyStateView.hide()
                return
            }
            self?.emptyStateView.show(type: type)
        }
        
        viewModel.onRecordUpdated = { [weak self] indexPath in
            self?.collectionView.reloadItems(at: [indexPath])
        }
        
        viewModel.onCategoriesChangedWithChanges = { [weak self] data in
            guard let self else { return }
            let (categories, changes) = data
            self.visibleCategories = categories
            self.applyCollectionChanges(changes)
        }
        
        viewModel.onFilterChanged = { [weak self] filter in
            guard let self else { return }
            self.filtersButton.showActive(filter.isActive)
            self.selectedFilter = filter
            if filter == .today {
                self.datePicker.date = Date()
                self.datePicker.sendActions(for: .valueChanged)
            }
            isFiltering = filter.isActive
        }
        
        viewModel.onFilteringAvailableChanged = { [weak self] isHidden in
            self?.filtersButton.isHidden = isHidden
        }
    }
    
    // MARK: - Private Properties
    private var visibleCategories: [TrackerCategory] = []
    private let viewModel: TrackersViewModel
    private var isFiltering = false
    private var selectedFilter: TrackerFilter?
    
    // MARK: - Initializers
    init(viewModel: TrackersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Actions
    @objc private func didTapAddTrackerButton() {
        let vc = CreateTrackerController()
        
        present(vc, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        Logger.info("Выбранная дата: \(sender.date)")
        viewModel.selectDate(sender.date)
    }
    
    @objc private func didTapFiltersButton() {
        let vc = FiltersViewController(filter: selectedFilter)
        vc.onFilterSelected = { [weak self] filter in
            self?.viewModel.selectFilter(filter)
        }
        
        present(vc, animated: true)
    }
    
    // MARK: - Private Methods
    private func loadData() {
        viewModel.selectDate(datePicker.date)
    }
    
    private func applyCollectionChanges(_ changes: [DataChange]) {
        guard !isFiltering else { return }
        collectionView.performBatchUpdates {
            for change in changes {
                switch change {
                case .insert(let indexPath):
                    collectionView.insertItems(at: [indexPath])
                case .delete(let indexPath):
                    collectionView.deleteItems(at: [indexPath])
                case .update(let indexPath):
                    collectionView.reloadItems(at: [indexPath])
                case .move(let from, let to):
                    collectionView.moveItem(at: from, to: to)
                case .insertSection(let section):
                    collectionView.insertSections(IndexSet(integer: section))
                case .deleteSection(let section):
                    collectionView.deleteSections(IndexSet(integer: section))
                }
            }
        } completion: { finished in
            guard finished else {
                Logger.error("Обновление коллекции прервано")
                return
            }
            
            for change in changes {
                switch change {
                case .insert(let indexPath):
                    Logger.debug("➕ Добавлен элемент в \(indexPath)")
                case .delete(let indexPath):
                    Logger.debug("➖ Удалён элемент из \(indexPath)")
                case .update(let indexPath):
                    Logger.debug("🔁 Обновлён элемент в \(indexPath)")
                case .move(let from, let to):
                    Logger.debug("↔️ Элемент перемещён из \(from) в \(to)")
                case .insertSection(let section):
                    Logger.debug("📂 Добавлена секция \(section)")
                case .deleteSection(let section):
                    Logger.debug("📁 Удалена секция \(section)")
                }
            }
            Logger.debug("✅ Применено \(changes.count) изменений")
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.delegate = self
        let cellData = viewModel.cellData(for: indexPath)
        cell.configure(
            with: cellData.tracker,
            isCompletedToday: cellData.isCompletedToday,
            indexPath: indexPath,
            completedDays: cellData.completedCount,
            datePickerDate: datePicker.date
        )
        cell.configureContextMenuDelegate(self)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionHeaderView.identifier, for: indexPath) as? CollectionHeaderView else {
            return UICollectionReusableView()
        }
        
        header.headerLabel.text = visibleCategories[indexPath.section].title
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellsPerRow: CGFloat = 2
        let leftInset: CGFloat = 16
        let rightInset: CGFloat = 16
        let cellSpacing: CGFloat = 9
        let paddingWidth: CGFloat = leftInset + rightInset + (cellsPerRow - 1) * cellSpacing
        let availableWidth = collectionView.frame.width - paddingWidth
        let cellWidth =  availableWidth / CGFloat(cellsPerRow)
        
        return CGSize(width: cellWidth, height: 148)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9 // cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 30)
    }
    
}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        viewModel.updateSearchQuery(text)
        isFiltering = !text.isEmpty
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func didTapQuantityManagementButton(from cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            Logger.error("Не удалось получить indexPath ячейки")
            return
        }
        viewModel.toggleTrackerRecord(at: indexPath)
    }
}

// MARK: - UIContextMenuInteractionDelegate
extension TrackersViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let cardView = interaction.view,
              let cell = cardView.superview(of: UICollectionViewCell.self),
              let indexPath = collectionView.indexPath(for: cell) else {
            return nil
        }
        
        let category = visibleCategories[indexPath.section]
        let tracker = category.trackers[indexPath.item]
        let count = viewModel.count(for: indexPath)
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: Layout.editButtonText) { [weak self] _ in
                self?.editTracker(tracker: tracker, category: category, count: count)
            }
            let deleteAction = UIAction(title: Layout.deleteButtonText, attributes: .destructive) { [weak self] _ in
                self?.showDeleteAlert(for: tracker)
            }
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    private func editTracker(tracker: Tracker, category: TrackerCategory, count: Int) {
        let vc = TrackerController(mode: .edit(type: .habit, tracker: tracker, category: category, count: count))
        present(vc, animated: true)
    }
    
    private func showDeleteAlert(for tracker: Tracker) {
        AlertHelper.showDeleteConfirmation(
            from: self,
            message: Layout.alertTrackerQuestion
        ) { [weak self] in
            self?.viewModel.deleteTracker(tracker)
        }
    }
}
