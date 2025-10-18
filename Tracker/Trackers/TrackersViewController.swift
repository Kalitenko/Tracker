import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Constants
    private enum Layout {
        static let trackersLabelText = "Трекеры"
        static let searchBarText = "Поиск"
        static let emptyStateLabelText = "Что будем отслеживать?"
        
        static let collectionViewTopInset: CGFloat = 24
        static let emptyStateViewTopInset: CGFloat = 220
        static let emptyStateViewHorizontalInset: CGFloat = 16
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
    
    private lazy var emptyStateView = EmptyStateView(text: Layout.emptyStateLabelText)
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        collectionView.register(CollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeaderView.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubViews()
        setupConstraints()
        configureUINavigationBar()
        
        dataObserver.delegate = self
        loadData()
        
        checkEmptyState()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = UIColor(resource: .white)
    }
    
    private func setupSubViews() {
        [emptyStateView, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        view.bringSubviewToFront(emptyStateView)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Трекеры"
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
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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
    
    
    // MARK: - Private Properties
    private let dataProvider: DataProvider = DataProvider.shared
    private let dataObserver: TrackersObserver = DataProvider.shared.trackersObserver
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    private func loadData() {
        reloadTrackerRecords()
        categories = dataProvider.categories(for: datePicker.date)
        visibleCategories = categories
        completedTrackers = dataProvider.completedTrackers
        collectionView.reloadData()
    }
    
    private func reloadTrackerRecords() {
        completedTrackers = dataProvider.completedTrackers
    }
    
    private func updateVisibleCategories() {
        categories = dataProvider.categories(for: datePicker.date)
        visibleCategories = categories
    }
    
    private func isTrackerCompletedTodayPredicate(record: TrackerRecord, for id: Int32) -> Bool {
        let isSameDay = Calendar.current.isDate(record.date, inSameDayAs: datePicker.date)
        return record.trackerId == id && isSameDay
    }
    
    private func isTrackerCompletedToday(id: Int32) -> Bool {
        completedTrackers.contains { isTrackerCompletedTodayPredicate(record: $0, for: id) }
    }
    
    private func countCompletedTrackers(id: Int32) -> Int {
        completedTrackers.filter { $0.trackerId == id }.count
    }
    
    
    private func filterCategories() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: datePicker.date)
        let filterText = searchController.searchBar.text ?? ""
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textMatch = filterText.isEmpty || tracker.name.range(of: filterText, options: [.caseInsensitive, .diacriticInsensitive]) != nil
                let dateMatch = tracker.schedule.contains { $0.calendarWeekday == weekday }
                return textMatch && dateMatch
            }
            if trackers.isEmpty { return nil }
            return TrackerCategory(title: category.title, trackers: trackers)
        }
        
        collectionView.reloadData()
        checkEmptyState()
    }
    
    private func checkEmptyState() {
        if visibleCategories.isEmpty {
            emptyStateView.show()
        } else {
            emptyStateView.hide()
        }
    }
    
    // MARK: - Actions
    @objc private func didTapAddTrackerButton() {
        let vc = CreateTrackerController()
        vc.delegate = self
        
        present(vc, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        Logger.info("Выбранная дата: \(sender.date)")
        loadData()
        filterCategories()
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
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let trackerId = tracker.id
        Logger.debug("id: \(trackerId)")
        let isCompletedToday = isTrackerCompletedToday(id: trackerId)
        Logger.debug("isCompletedToday: \(isCompletedToday)")
        let count = countCompletedTrackers(id: trackerId)
        cell.configure(with: tracker, isCompletedToday: isCompletedToday, indexPath: indexPath, completedDays: count, datePickerDate: datePicker.date)
        
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

extension TrackersViewController: TrackersObserverDelegate {
    func didUpdateTrackers(_ changes: [DataChange]) {
        self.updateVisibleCategories()
        
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
    
    func didUpdateRecords(record: TrackerRecord, changeType: DataChangeType) {
        switch changeType {
        case .insert:
            completedTrackers.append(record)
        case .delete:
            completedTrackers.removeAll { $0.trackerId == record.trackerId && Calendar.current.isDate($0.date, inSameDayAs: record.date) }
        default: break
        }
        
        if let indexPath = indexPathForTracker(record.trackerId) {
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    private func indexPathForTracker(_ trackerId: Int32) -> IndexPath? {
        for (sectionIndex, category) in visibleCategories.enumerated() {
            if let itemIndex = category.trackers.firstIndex(where: { $0.id == trackerId }) {
                return IndexPath(item: itemIndex, section: sectionIndex)
            }
        }
        return nil
    }
    
}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterCategories()
    }
}

// MARK: - NewTrackerDelegate
extension TrackersViewController: NewTrackerDelegate {
    func didCreateNewTracker(tracker: Tracker, categoryTitle: String) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func didTapQuantityManagementButton(id: Int32, at indexPath: IndexPath) {
        let isCompletedToday = isTrackerCompletedToday(id: id)
        if isCompletedToday {
            removeTrackerRecord(id: id, at: indexPath)
        } else {
            addTrackerRecord(id: id, at: indexPath)
        }
    }
    
    private func addTrackerRecord(id: Int32, at indexPath: IndexPath) {
        let trackerRecord = TrackerRecord(trackerId: id, date: datePicker.date)
        dataProvider.addRecord(trackerRecord)
        Logger.info("Выполнен трекер \(trackerRecord.trackerId) на \(trackerRecord.date)")
    }
    
    private func removeTrackerRecord(id: Int32, at indexPath: IndexPath) {
        completedTrackers
            .filter { isTrackerCompletedTodayPredicate(record: $0, for: id) }
            .forEach { record in
                Logger.debug("Удаляем отметку о трекере с ID: \(record.trackerId)")
                dataProvider.deleteRecord(record)
            }
        Logger.info("Удалена отметка о выполнении трекера \(id)")
    }
    
}
