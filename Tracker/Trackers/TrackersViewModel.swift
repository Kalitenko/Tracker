import Foundation

struct TrackerCellData {
    let tracker: Tracker
    let isCompletedToday: Bool
    let completedCount: Int
}

final class TrackersViewModel {
    
    // MARK: - Public Properties
    var onDateChanged: Binding<Date>?
    var onVisibleCategoriesChanged: Binding<[TrackerCategory]>?
    var onEmptyStateChanged: Binding<Bool>?
    var onCategoriesChangedWithChanges: Binding<([TrackerCategory], [DataChange])>?
    var onRecordUpdated: Binding<IndexPath>?
    
    // MARK: - Private Properties
    private var selectedDate: Date {
        didSet {
            onDateChanged?(selectedDate)
        }
    }
    private let dataProvider: DataProvider = DataProvider.shared
    private let dataObserver: TrackersObserver = DataProvider.shared.trackersObserver
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentQuery: String = ""{
        didSet {
            filterCategories()
        }
    }
    
    // MARK: - Initializers
    init() {
        self.selectedDate = Date()
        dataObserver.delegate = self
        loadCompletedTrackers()
    }
    
    // MARK: - Public Methods
    func selectDate(_ date: Date) {
        selectedDate = date
        loadCategories(for: date)
    }
    
    func updateSearchQuery(_ text: String) {
        currentQuery = text
    }
    
    func cellData(for indexPath: IndexPath) -> TrackerCellData {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        return TrackerCellData(
            tracker: tracker,
            isCompletedToday: isTrackerCompletedToday(id: tracker.id),
            completedCount: countCompletedTrackers(id: tracker.id)
        )
    }
    
    func toggleTrackerRecord(at indexPath: IndexPath) {
        let id = visibleCategories[indexPath.section].trackers[indexPath.item].id
        let isCompletedToday = isTrackerCompletedToday(id: id)
        if isCompletedToday {
            removeTrackerRecord(id: id, at: indexPath)
        } else {
            addTrackerRecord(id: id, at: indexPath)
        }
    }
    
    // MARK: - Private Methods
    private func loadCategories(for date: Date) {
        categories = dataProvider.categories(for: date)
        visibleCategories = categories
        onVisibleCategoriesChanged?(visibleCategories)
        updateEmptyState()
    }
    
    private func loadCompletedTrackers() {
        completedTrackers = dataProvider.completedTrackers
    }
    
    private func addTrackerRecord(id: Int32, at indexPath: IndexPath) {
        let trackerRecord = TrackerRecord(trackerId: id, date: selectedDate)
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
    
    private func isTrackerCompletedTodayPredicate(record: TrackerRecord, for id: Int32) -> Bool {
        let isSameDay = Calendar.current.isDate(record.date, inSameDayAs: selectedDate)
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
        let weekday = calendar.component(.weekday, from: selectedDate)
        let filterText = currentQuery
        
        Logger.debug("filterText: \(filterText)")
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textMatch = filterText.isEmpty || tracker.name.range(of: filterText, options: [.caseInsensitive, .diacriticInsensitive]) != nil
                let dateMatch = tracker.schedule.contains { $0.calendarWeekday == weekday }
                return textMatch && dateMatch
            }
            if trackers.isEmpty { return nil }
            return TrackerCategory(title: category.title, trackers: trackers)
        }
        
        onVisibleCategoriesChanged?(visibleCategories)
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        onEmptyStateChanged?(visibleCategories.isEmpty)
    }
    
}

extension TrackersViewModel: TrackersObserverDelegate {
    func didUpdateTrackers(_ changes: [DataChange]) {
        categories = dataProvider.categories(for: selectedDate)
        onCategoriesChangedWithChanges?((categories, changes))
        onEmptyStateChanged?(visibleCategories.isEmpty)
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
            onRecordUpdated?(indexPath)
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
