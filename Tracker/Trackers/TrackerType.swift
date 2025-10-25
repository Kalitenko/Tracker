enum TrackerType {
    case habit
    case irregular
    
    var titleText: String {
        switch self {
        case .habit: "Новая привычка"
        case .irregular: "Новое нерегулярное событие"
        }
    }
    
    var options: [String] {
        switch self {
        case .habit: ["Категория", "Расписание"]
        case .irregular: ["Категория"]
        }
    }
}
