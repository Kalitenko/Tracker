enum TrackerFilter: CaseIterable {
    case all
    case today
    case completed
    case notCompleted
    
    var title: String {
        switch self {
        case .all: L10n.all
        case .today: L10n.today
        case .completed: L10n.completed
        case .notCompleted: L10n.notCompleted
        }
    }
    
    var isActive: Bool {
        switch self {
        case .completed, .notCompleted: true
        default: false
        }
    }
}
