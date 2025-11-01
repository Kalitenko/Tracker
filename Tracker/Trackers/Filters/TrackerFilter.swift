enum TrackerFilter: CaseIterable {
    case all
    case today
    case completed
    case notCompleted
    
    var title: String {
        switch self {
        case .all: "Все трекеры"
        case .today: "Трекеры на сегодня"
        case .completed: "Завершенные"
        case .notCompleted: "Не завершенные"
        }
    }
    
    var isActive: Bool {
        switch self {
        case .completed, .notCompleted: true
        default: false
        }
    }
}
