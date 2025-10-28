enum TrackerType {
    case habit
    case irregular
    
    var titleText: String {
        switch self {
        case .habit: L10n.newHabit
        case .irregular: L10n.newIrregularEvent
        }
    }
    
    var options: [String] {
        switch self {
        case .habit: [L10n.category, L10n.schedule]
        case .irregular: [L10n.category]
        }
    }
}
