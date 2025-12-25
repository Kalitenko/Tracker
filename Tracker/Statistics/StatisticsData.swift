enum StatisticsMetric: CaseIterable {
    case bestPeriod
    case bestPeriodPerTracker
    case idealDays
    case completedTrackers
    case averageValue

    var title: String {
        switch self {
        case .bestPeriod: L10n.bestPeriod
        case .bestPeriodPerTracker: L10n.bestPeriodPerTracker
        case .idealDays: L10n.idealDays
        case .completedTrackers: L10n.completedTrackers
        case .averageValue: L10n.averageValue
        }
    }
}

struct StatisticsData {
    let metric: StatisticsMetric
    let data: String
}
