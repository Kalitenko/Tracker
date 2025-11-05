@testable import Tracker
import UIKit

final class MockEmptyTrackersViewModel: TrackersViewModelProtocol {
    var onDateChanged: Binding<Date>?
    var onVisibleCategoriesChanged: Binding<[TrackerCategory]>?
    var onEmptyStateChanged: Binding<EmptyStateViewType?>?
    var onCategoriesChangedWithChanges: Binding<([TrackerCategory], [DataChange])>?
    var onRecordUpdated: Binding<IndexPath>?
    var onFilterChanged: Binding<TrackerFilter>?
    var onFilteringAvailableChanged: Binding<Bool>?

    func selectDate(_ date: Date) {
        let type: EmptyStateViewType = .trackers
        onEmptyStateChanged?(type)
        onFilteringAvailableChanged?(true)
    }
    func updateSearchQuery(_ text: String) {}
    func cellData(for indexPath: IndexPath) -> TrackerCellData {
        let tracker: Tracker = .init(id: 1, name: "", color: UIColor.clear, emoji: "", schedule: [], isHabit: true, isPinned: false)
        
        return TrackerCellData(tracker: tracker, isCompletedToday: false, completedCount: 0)
    }
    func toggleTrackerRecord(at indexPath: IndexPath) {}
    func count(for indexPath: IndexPath) -> Int {
        return 0
    }
    func deleteTracker(_ tracker: Tracker) {}
    func selectFilter(_ filter: TrackerFilter) {}
    func pinToggle(tracker: Tracker) {}
}
