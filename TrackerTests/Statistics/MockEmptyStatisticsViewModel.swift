@testable import Tracker

final class MockEmptyStatisticsViewModel: StatisticsViewModelProtocol {
    var onStatisticsChanged: Binding<[StatisticsData]>?
    var onEmptyStateChanged: Binding<EmptyStateViewType?>?
    var onIdealDaysRecalculated: Binding<StatisticsData?>?
    
    private let completedTrackers = 0
    
    func loadStatistics() {
        updateEmptyState()
    }
    
    // MARK: - Private Methods
    private func updateEmptyState() {
        let type = completedTrackers == 0 ? EmptyStateViewType.statistics : nil
        onEmptyStateChanged?(type)
    }
}
