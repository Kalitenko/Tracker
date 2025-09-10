import UIKit

final class TrackersViewController: UIViewController {
    
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
        collectionView.register(TrackerCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerCollectionHeaderView.identifier)
        
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
        
        dumbData()
        checkEmptyState()
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
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
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
    var trackers: [Tracker] = []
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    func dumbData() {
        let workTrackers = TrackerCategory(
            id: 1,
            title: "Работа",
            trackers: [
                Tracker(
                    id: 101,
                    name: "Утренняя планёрка",
                    color: .systemBlue,
                    emoji: "📋",
                    schedule: [.monday, .wednesday, .friday]
                ),
                Tracker(
                    id: 102,
                    name: "Проверка почты",
                    color: .systemTeal,
                    emoji: "📧",
                    schedule: [.monday, .tuesday, .wednesday, .thursday, .friday]
                ),
                Tracker(
                    id: 103,
                    name: "Код-ревью",
                    color: .systemOrange,
                    emoji: "💻",
                    schedule: [.tuesday, .thursday]
                )
            ]
        )
        
        let healthTrackers = TrackerCategory(
            id: 2,
            title: "Здоровье",
            trackers: [
                Tracker(
                    id: 201,
                    name: "Утренняя пробежка",
                    color: .systemGreen,
                    emoji: "🏃‍♂️",
                    schedule: [.monday, .wednesday, .friday, .sunday]
                ),
                Tracker(
                    id: 202,
                    name: "Медитация",
                    color: .systemPurple,
                    emoji: "🧘‍♀️",
                    schedule: [.wednesday]
                )
            ]
        )
        
        let hobbyTrackers = TrackerCategory(
            id: 3,
            title: "Хобби",
            trackers: [
                Tracker(
                    id: 301,
                    name: "Играть на гитаре",
                    color: .systemRed,
                    emoji: "🎸",
                    schedule: [.saturday, .sunday]
                )
            ]
        )
        
        categories = [workTrackers, healthTrackers, hobbyTrackers]
        trackers = categories.flatMap { $0.trackers }
        
        let today = Date()
        let calendar = Calendar.current
        
        let trackerRecords: [TrackerRecord] = [
            TrackerRecord(trackerId: 101, date: today),
            TrackerRecord(trackerId: 101, date: calendar.date(byAdding: .day, value: -1, to: today)!),
            TrackerRecord(trackerId: 101, date: calendar.date(byAdding: .day, value: -2, to: today)!),
            
            TrackerRecord(trackerId: 102, date: today),
            TrackerRecord(trackerId: 103, date: today)
        ]
        
        completedTrackers = trackerRecords
        
    }
    
    // MARK: - Private Methods
    private func checkEmptyState() {
        if trackers.isEmpty {
            emptyStateImageView.isHidden = false
            emptyStateLabel.isHidden = false
        } else {
            emptyStateImageView.isHidden = true
            emptyStateLabel.isHidden = true
        }
    }
    
    private func isTrackerCompletedTodayPredicate(record: TrackerRecord, for id: UInt) -> Bool {
        let isSameDay = Calendar.current.isDate(record.date, inSameDayAs: datePicker.date)
        return record.trackerId == id && isSameDay
    }
    
    private func isTrackerCompletedToday(id: UInt) -> Bool {
        completedTrackers.contains { isTrackerCompletedTodayPredicate(record: $0, for: id) }
    }
    
    private func countCompletedTrackers(id: UInt) -> Int {
        completedTrackers.filter { $0.trackerId == id }.count
    }
    
    
    // MARK: - Actions
    @objc private func didTapAddTrackerButton(_ sender: Any) {
        Logger.info("didTapAddTrackerButton was clicked")
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        Logger.info("Выбранная дата: \(formattedDate)")
        collectionView.reloadData()
    }
    
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let category = categories[indexPath.section]
        let tracker = category.trackers[indexPath.row]
        
        cell.delegate = self
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let count = countCompletedTrackers(id: tracker.id)
        cell.configure(with: tracker, isCompletedToday: isCompletedToday, indexPath: indexPath, completedDays: count, datePickerDate: datePicker.date)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerCollectionHeaderView.identifier, for: indexPath) as? TrackerCollectionHeaderView else {
            return UICollectionReusableView()
        }
        header.headerLabel.text = categories[indexPath.section].title
        
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

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func didTapQuantityManagementButton(id: UInt, at indexPath: IndexPath) {
        let isCompletedToday = isTrackerCompletedToday(id: id)
        if isCompletedToday {
            removeTrackerRecord(id: id, at: indexPath)
        } else {
            addTrackerRecord(id: id, at: indexPath )
        }
    }
    
    private func addTrackerRecord(id: UInt, at indexPath: IndexPath) {
        let trackerRecord = TrackerRecord(trackerId: id, date: datePicker.date)
        completedTrackers.append(trackerRecord)
        Logger.info("Выполнен трекер \(trackerRecord.trackerId) на \(trackerRecord.date)")
        collectionView.reloadItems(at: [indexPath])
    }
    
    private func removeTrackerRecord(id: UInt, at indexPath: IndexPath) {
        completedTrackers.removeAll {
            isTrackerCompletedTodayPredicate(record: $0, for: id)
        }
        Logger.info("Удалена отметка о выполнении трекера \(id)")
        collectionView.reloadItems(at: [indexPath])
    }
    
}

// MARK: - Preview
#Preview("Only Tracker Controller") {
    let vc = TrackersViewController()
    //    vc.trackers = []
    return vc
}

#Preview("TabBarController") {
    let vc = TabBarController()
    
    return vc
}
