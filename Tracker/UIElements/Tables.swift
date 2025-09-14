import UIKit

enum TableStyle {
    case checkmark
    case arrow
    case toggle

    var cellType: UITableViewCell.Type {
        switch self {
        case .checkmark: return CheckmarkCell.self
        case .arrow: return ArrowCell.self
        case .toggle: return ToggleCell.self
        }
    }

    var reuseIdentifier: String {
        switch self {
        case .checkmark: return "CheckmarkCell"
        case .arrow: return "ArrowCell"
        case .toggle: return "ToggleCell"
        }
    }
}

final class Table: UITableView {
    
    init(style: TableStyle) {
        super.init(frame: .zero, style: .plain)
        
        self.layer.cornerRadius = 16
        self.separatorStyle = .singleLine
        
        self.register(style.cellType, forCellReuseIdentifier: style.reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
