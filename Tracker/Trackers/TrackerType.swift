enum TrackerType {
    case habit
    case irregular
    
    var titleText: String {
        switch self {
        case .habit: return "Новая привычка"
        case .irregular: return "Новое нерегулярное событие"
        }
    }
    
    var options: [String] {
        switch self {
        case .habit: return ["Категория", "Расписание"]
        case .irregular: return ["Категория"]
        }
    }
}
