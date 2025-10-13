import UIKit

final class OldTrackersViewController: UIViewController {
    
    // MARK: - Constants
    private enum Layout {
        static let trackersLabelText = "Трекеры"
        static let searchBarText = "Поиск"
        static let emptyStateLabelText = "Что будем отслеживать?"
        
        static let emptyStateImageTopInset: CGFloat = 220
        static let emptyStateLabelTopSpacing: CGFloat = 8
        static let emptyStateLabelHorizontalInset: CGFloat = 16
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
    
    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .emptyState))
        imageView.contentMode = .center
        
        return imageView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = Layout.emptyStateLabelText
        label.textAlignment = .center
        label.textColor = UIColor(resource: .black)
        label.font = UIFont.medium12
        
        return label
    }()
    
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
        
        checkEmptyState()
        dataObserver.delegate = self
        reloadData()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = UIColor(resource: .white)
    }
    
    private func setupSubViews() {
        [emptyStateImageView, emptyStateLabel, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        view.bringSubviewToFront(emptyStateLabel)
        view.bringSubviewToFront(emptyStateImageView)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Трекеры"
    }
    
    private func setupConstraints() {
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            emptyStateImageView.topAnchor.constraint(equalTo: guide.topAnchor, constant: Layout.emptyStateImageTopInset),
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: Layout.emptyStateLabelTopSpacing),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.emptyStateLabelHorizontalInset),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.emptyStateLabelHorizontalInset),
            
            collectionView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 24),
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
    
    // MARK: - Public Properties
    var categories: [TrackerCategory] = []
    var visibleCategories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    // MARK: - Private Properties
    private let dataProvider: DataProviderProtocol = DataProvider.shared
    private let dataObserver: DataObserver = DataProvider.shared.observer
    
    // MARK: - Data
    private func reloadData() {
        categories = dataProvider.categories
        completedTrackers = dataProvider.completedTrackers
        Logger.debug("Количество категорий: \(categories.count)")
        Logger.debug("Количество завершенных записей: \(completedTrackers.count)")
        filterCategories()
    }
    
    // MARK: - Private Methods
    private func checkEmptyState() {
        if visibleCategories.isEmpty {
            emptyStateImageView.isHidden = false
            emptyStateLabel.isHidden = false
        } else {
            emptyStateImageView.isHidden = true
            emptyStateLabel.isHidden = true
        }
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
     
    // MARK: - Actions
    @objc private func didTapAddTrackerButton(_ sender: Any) {
        let vc = CreateTrackerController()
        vc.delegate = self
        
        present(vc, animated: true)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        Logger.info("Выбранная дата: \(sender.date)")
        filterCategories()
    }
    
    private func filterCategories() {
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: datePicker.date)
        let filterText = searchController.searchBar.text ?? ""
        
        visibleCategories = categories.compactMap { category in
            
            let trackers = category.trackers.filter { tracker in
                
                
                let textCondition = filterText.isEmpty || tracker.name.range(
                    of: filterText,
                    options: [.caseInsensitive, .diacriticInsensitive],
                    locale: .current
                ) != nil
                
                let dateCondition = tracker.schedule.contains {
                    $0.calendarWeekday == filterWeekday
                }
                return textCondition && dateCondition
            }
            
            if trackers.isEmpty { return nil }
            
            return TrackerCategory(
                title: category.title,
                trackers: trackers
            )
        }
        visibleCategories = sortTrackers(in: visibleCategories)
        collectionView.reloadData()
        checkEmptyState()
    }
    
    private func sortTrackers(in categories: [TrackerCategory]) -> [TrackerCategory] {
        return categories.map { category in
            let sortedTrackers = category.trackers.sorted { $0.id < $1.id }
            return TrackerCategory(title: category.title, trackers: sortedTrackers)
        }
    }
    
}

// MARK: - UICollectionViewDataSource
extension OldTrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let category = visibleCategories[indexPath.section]
        let tracker = category.trackers[indexPath.row]
        Logger.debug("id: \(tracker.id)")
        let trackerId = tracker.id
        
        cell.delegate = self
        Logger.debug("id: \(trackerId)")
        let isCompletedToday = isTrackerCompletedToday(id: trackerId)
        Logger.debug("isCompletedToday: \(isTrackerCompletedToday)")
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
extension OldTrackersViewController: UICollectionViewDelegateFlowLayout {
    
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

// MARK: - TrackerCellDelegate
extension OldTrackersViewController: TrackerCellDelegate {
    func didTapQuantityManagementButton(id: Int32, at indexPath: IndexPath) {
        let isCompletedToday = isTrackerCompletedToday(id: id)
        if isCompletedToday {
            removeTrackerRecord(id: id, at: indexPath)
        } else {
            addTrackerRecord(id: id, at: indexPath )
        }
    }
    
    private func addTrackerRecord(id: Int32, at indexPath: IndexPath) {
        let trackerRecord = TrackerRecord(trackerId: id, date: datePicker.date)
        dataProvider.addRecord(trackerRecord)
        Logger.info("Выполнен трекер \(trackerRecord.trackerId) на \(trackerRecord.date)")
        collectionView.reloadItems(at: [indexPath])
    }
    
    private func removeTrackerRecord(id: Int32, at indexPath: IndexPath) {
        completedTrackers
            .filter { isTrackerCompletedTodayPredicate(record: $0, for: id) }
            .forEach { record in
                Logger.debug("Удаляем отметку о трекере с ID: \(record.trackerId)")
            dataProvider.deleteRecord(record)
        }
        Logger.info("Удалена отметка о выполнении трекера \(id)")
        collectionView.reloadItems(at: [indexPath])
    }
    
}

// MARK: -
extension OldTrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        if !searchText.isEmpty {
            Logger.info("Поиск по тексту: \(searchText)")
        }
        
        filterCategories()
    }
}

// MARK: - NewTrackerDelegate
extension OldTrackersViewController: NewTrackerDelegate {
    func didCreateNewTracker(tracker: Tracker, categoryTitle: String) {
        
        filterCategories()
        dismiss(animated: true, completion: nil)
    }
}

extension OldTrackersViewController: DataObserverDelegate {
    func didUpdateTrackers(_ changes: [DataChange]) {
        reloadData()
    }
    
    func didUpdateCategories() {
        Logger.debug("🩼 Не должно вызываться!")
        reloadData()
    }
    
    func didUpdateRecords(record: TrackerRecord, changeType: DataChangeType) {
        reloadData()
    }
}

// MARK: - Preview
#if DEBUG
extension OldTrackersViewController {
    func loadPreviewData() {
        categories = dataProvider.categories
        completedTrackers = dataProvider.completedTrackers
        filterCategories()
    }
}
#endif

#Preview("Only Tracker Controller") {
    let vc = OldTrackersViewController()
    vc.loadPreviewData()
    return vc
}

#Preview("TabBarController") {
    let vc = TabBarController()
    vc.loadPreviewData()
    return vc
}
