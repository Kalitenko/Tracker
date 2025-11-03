enum StatisticsMetric: CaseIterable {
    case bestPeriod
    case bestPeriodPerTracker
    case idealDays
    case completedTrackers
    case averageValue

    var title: String {
        switch self {
        case .bestPeriod: "Лучший период по всем трекерам"
        case .bestPeriodPerTracker: "Лучший период для одного трекера"
        case .idealDays: "Идеальные дни"
        case .completedTrackers: "Трекеров завершено"
        case .averageValue: "Среднее значение"
        }
    }
}

struct StatisticsData {
    let metric: StatisticsMetric
    let data: String
}
