@testable import Tracker
import UIKit

final class MockTrackersViewModel: TrackersViewModelProtocol {
    var onDateChanged: Binding<Date>?
    var onVisibleCategoriesChanged: Binding<[TrackerCategory]>?
    var onEmptyStateChanged: Binding<EmptyStateViewType?>?
    var onCategoriesChangedWithChanges: Binding<([TrackerCategory], [DataChange])>?
    var onRecordUpdated: Binding<IndexPath>?
    var onFilterChanged: Binding<TrackerFilter>?
    var onFilteringAvailableChanged: Binding<Bool>?

    func selectDate(_ date: Date) {
        onVisibleCategoriesChanged?(categories)
    }
    func updateSearchQuery(_ text: String) {}
    func cellData(for indexPath: IndexPath) -> TrackerCellData {
        let tracker = categories[indexPath.section].trackers[indexPath.item]
        return TrackerCellData(
            tracker: tracker,
            isCompletedToday: false,
            completedCount: 0
        )
    }
    func toggleTrackerRecord(at indexPath: IndexPath) {}
    func count(for indexPath: IndexPath) -> Int {
        return 0
    }
    func deleteTracker(_ tracker: Tracker) {}
    func selectFilter(_ filter: TrackerFilter) {}
    func pinToggle(tracker: Tracker) {}
    
    private let dataProvider: DataProviderProtocol
    private let categories: [TrackerCategory]
    
    init() {
        dataProvider = MockDataProvider.shared
        categories = dataProvider.categories
    }
}
