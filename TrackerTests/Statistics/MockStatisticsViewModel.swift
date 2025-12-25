@testable import Tracker

final class MockStatisticsViewModel: StatisticsViewModelProtocol {
    var onStatisticsChanged: Binding<[StatisticsData]>?
    var onEmptyStateChanged: Binding<EmptyStateViewType?>?
    var onIdealDaysRecalculated: Binding<StatisticsData?>?
    
    private let bestPeriod = 5
    private let bestPeriodPerTracker = 3
    private let idealDays = 6
    private let completedTrackers = 36
    private let averageValue = 3.5
    
    func loadStatistics() {
        let statisticsData: [StatisticsData]  = [
            .init(metric: .bestPeriod, data: bestPeriod.description),
            .init(metric: .bestPeriodPerTracker, data: bestPeriodPerTracker.description),
            .init(metric: .idealDays, data: idealDays.description),
            .init(metric: .completedTrackers, data: completedTrackers.description),
            .init(metric: .averageValue, data: Utils.localizedNumber(averageValue))
        ]
        
        onStatisticsChanged?(statisticsData)
        updateEmptyState()
    }
    
    // MARK: - Private Methods
    private func updateEmptyState() {
        let type = completedTrackers == 0 ? EmptyStateViewType.statistics : nil
        onEmptyStateChanged?(type)
    }
}
