enum Mode {
    case create
    case edit(TrackerCategory)
    
    var title: String {
        switch self {
        case .create: "Новая категория"
        case .edit: "Редактирование категории"
        }
    }
}
