enum Mode {
    case create
    case edit(TrackerCategory)
    
    var title: String {
        switch self {
        case .create: L10n.newCategory
        case .edit: L10n.editCategory
        }
    }
}
