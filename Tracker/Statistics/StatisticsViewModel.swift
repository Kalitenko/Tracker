import Foundation

final class StatisticsViewModel {
    
    // MARK: - Public Properties
    var onStatisticsChanged: Binding<[StatisticsData]>?
    var onEmptyStateChanged: Binding<EmptyStateViewType?>?
    var onIdealDaysRecalculated: Binding<StatisticsData?>?
    
    // MARK: - Private Properties
    private var statisticsData: [StatisticsData] = []
    private let dataProvider: StatisticsDataProviderProtocol = StatisticsDataProvider.shared
    private let dataObserver: StatisticsObserverProtocol = StatisticsObserver.shared
    private var bestPeriod = Int.zero
    private var bestPeriodPerTracker = Int.zero
    private var idealDays = Int.zero
    private var completedTrackers = Int.zero
    private var averageValue = Double.zero
    
    // MARK: - Initializers
    init() {
        dataObserver.delegate = self
    }
    
    // MARK: - Private Methods
    private func updateEmptyState() {
        let type = completedTrackers == 0 ? EmptyStateViewType.statistics : nil
        onEmptyStateChanged?(type)
    }
    
    // MARK: - Public Methods
    func loadStatistics() {
        completedTrackers = dataProvider.completedTrackers()
        Logger.debug("completedTrackers: \(completedTrackers)")
        if completedTrackers > 0 {
            bestPeriod = dataProvider.bestPeriod()
            bestPeriodPerTracker = dataProvider.bestPeriodPerTracker()
            idealDays = dataProvider.idealDays()
            averageValue = dataProvider.averagePerDay()
            
            statisticsData = [
                .init(metric: .bestPeriod, data: bestPeriod.description),
                .init(metric: .bestPeriodPerTracker, data: bestPeriodPerTracker.description),
                .init(metric: .idealDays, data: idealDays.description),
                .init(metric: .completedTrackers, data: completedTrackers.description),
                .init(metric: .averageValue, data: Utils.localizedNumber(averageValue))
            ]
            
            onStatisticsChanged?(statisticsData)
        } else {
            onStatisticsChanged?([])
        }
        updateEmptyState()
    }
    
    // MARK: - Private Methods
    private func updateIdealDays() {
        idealDays = dataProvider.idealDays()
        onIdealDaysRecalculated?(StatisticsData(metric: .idealDays, data: idealDays.description))
    }
}

extension StatisticsViewModel: StatisticsObserverDelegate {
    func calculateIdealDays() {
        updateIdealDays()
    }
    
    func calculateStatistics() {
        loadStatistics()
    }
}
