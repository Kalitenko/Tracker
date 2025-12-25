enum TrackerType {
    case habit
    case irregular
    
    var options: [String] {
        switch self {
        case .habit: [L10n.category, L10n.schedule]
        case .irregular: [L10n.category]
        }
    }
}

enum TrackerMode {
    case create(TrackerType)
    case edit(type: TrackerType, tracker: Tracker, category: TrackerCategory, count: Int)
    
    var trackerType: TrackerType {
        switch self {
        case .create(let type): type
        case .edit(let type, _, _, _): type
        }
    }
    
    var titleText: String {
        switch self {
        case .create(let type):
            switch type {
            case .habit: L10n.newHabit
            case .irregular: L10n.newIrregularEvent
            }
        case .edit(let type, _, _, _):
            switch type {
            case .habit: L10n.editHabit
            case .irregular: L10n.editIrregularEvent
            }
        }
    }
}
