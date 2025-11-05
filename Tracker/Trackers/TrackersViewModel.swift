import Foundation

struct TrackerCellData {
    let tracker: Tracker
    let isCompletedToday: Bool
    let completedCount: Int
}

import Foundation

protocol TrackersViewModelProtocol: AnyObject {
    var onDateChanged: Binding<Date>? { get set }
    var onVisibleCategoriesChanged: Binding<[TrackerCategory]>? { get set }
    var onEmptyStateChanged: Binding<EmptyStateViewType?>? { get set }
    var onCategoriesChangedWithChanges: Binding<([TrackerCategory], [DataChange])>? { get set }
    var onRecordUpdated: Binding<IndexPath>? { get set }
    var onFilterChanged: Binding<TrackerFilter>? { get set }
    var onFilteringAvailableChanged: Binding<Bool>? { get set }

    func selectDate(_ date: Date)
    func updateSearchQuery(_ text: String)
    func cellData(for indexPath: IndexPath) -> TrackerCellData
    func toggleTrackerRecord(at indexPath: IndexPath)
    func count(for indexPath: IndexPath) -> Int
    func deleteTracker(_ tracker: Tracker)
    func selectFilter(_ filter: TrackerFilter)
    func pinToggle(tracker: Tracker)
}

final class TrackersViewModel: TrackersViewModelProtocol {
    
    // MARK: - Public Properties
    var onDateChanged: Binding<Date>?
    var onVisibleCategoriesChanged: Binding<[TrackerCategory]>?
    var onEmptyStateChanged: Binding<EmptyStateViewType?>?
    var onCategoriesChangedWithChanges: Binding<([TrackerCategory], [DataChange])>?
    var onRecordUpdated: Binding<IndexPath>?
    var onFilterChanged: Binding<TrackerFilter>?
    var onFilteringAvailableChanged: Binding<Bool>?
    
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
    private var currentQuery: String = "" {
        didSet {
            filterCategories()
        }
    }
    private var selectedFilter: TrackerFilter = .all {
        didSet {
            onFilterChanged?(selectedFilter)
        }
    }
    
    // MARK: - Initializers
    init() {
        self.selectedDate = Date()
        dataObserver.delegate = self
    }
    
    // MARK: - Public Methods
    func selectDate(_ date: Date) {
        selectedDate = date
        loadCategories(for: date)
        loadCompletedTrackers()
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
        Logger.debug("indexPath.section \(indexPath.section), indexPath.item \(indexPath.item)")
        let id = visibleCategories[indexPath.section].trackers[indexPath.item].id
        Logger.debug("id \(id), нажали на трекер c name \(visibleCategories[indexPath.section].trackers[indexPath.item].name)")
        let isCompletedToday = isTrackerCompletedToday(id: id)
        if isCompletedToday {
            removeTrackerRecord(id: id, at: indexPath)
        } else {
            addTrackerRecord(id: id, at: indexPath)
        }
    }
    
    func count(for indexPath: IndexPath) -> Int {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        return countCompletedTrackers(id: tracker.id)
    }
    
    func deleteTracker(_ tracker: Tracker) {
        dataProvider.deleteTracker(tracker)
    }
    
    func selectFilter(_ filter: TrackerFilter) {
        selectedFilter = filter
        Logger.debug("Выбран фильтр \(filter)")
        filterCategories()
    }
    
    func pinToggle(tracker: Tracker) {
        if tracker.isPinned {
            dataProvider.unpinTracker(tracker)
        } else {
            dataProvider.pinTracker(tracker)
        }
    }
    
    // MARK: - Private Methods
    private func loadCategories(for date: Date) {
        categories = dataProvider.categories(for: date)
        visibleCategories = categories
        onVisibleCategoriesChanged?(visibleCategories)
        updateEmptyState()
        updateFilteringAvailability()
    }
    
    private func loadCompletedTrackers() {
        let ids = categories.flatMap { $0.trackers.map { $0.id }}
        completedTrackers = dataProvider.completedTrackers(ids: ids)
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
        let filterText = currentQuery
        
        Logger.debug("filterText: \(filterText)")
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textMatch = filterText.isEmpty || tracker.name.range(of: filterText, options: [.caseInsensitive, .diacriticInsensitive]) != nil
                return textMatch
            }
            if trackers.isEmpty { return nil }
            return TrackerCategory(title: category.title, trackers: trackers)
        }
        
        if selectedFilter == .completed {
            visibleCategories = visibleCategories.compactMap { category in
                let trackers = category.trackers.filter { isTrackerCompletedToday(id: $0.id) }
                if trackers.isEmpty { return nil }
                return TrackerCategory(title: category.title, trackers: trackers)
            }
        }
        
        if selectedFilter == .notCompleted {
            visibleCategories = visibleCategories.compactMap { category in
                let trackers = category.trackers.filter { !isTrackerCompletedToday(id: $0.id) }
                if trackers.isEmpty { return nil }
                return TrackerCategory(title: category.title, trackers: trackers)
            }
        }
        
        onVisibleCategoriesChanged?(visibleCategories)
        updateEmptyState()
        
    }
    
    private func updateEmptyState() {
        let type: EmptyStateViewType?
        if categories.isEmpty {
            type = .trackers
        } else if visibleCategories.isEmpty {
            type = .filtering
        } else {
            type = nil
        }
        onEmptyStateChanged?(type)
    }
    
    private func updateFilteringAvailability() {
        onFilteringAvailableChanged?(visibleCategories.isEmpty)
    }
    
}

// MARK: - TrackersObserverDelegate
extension TrackersViewModel: TrackersObserverDelegate {
    func didUpdateTrackers(_ changes: [DataChange]) {
        categories = dataProvider.categories(for: selectedDate)
        visibleCategories = categories
        onCategoriesChangedWithChanges?((categories, changes))
        let isInsert = changes.contains {
            switch $0 {
            case .insert, .insertSection: return true
            default: return false
            }
        }
        if isInsert {
            loadCompletedTrackers()
        }
        updateEmptyState()
        updateFilteringAvailability()
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
