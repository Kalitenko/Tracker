import UIKit

enum TableStyle {
    case checkmark
    case arrow
    case toggle
    case statistics
    
    var cellType: UITableViewCell.Type {
        switch self {
        case .checkmark: CheckmarkCell.self
        case .arrow: ArrowCell.self
        case .toggle: ToggleCell.self
        case .statistics: StatisticsCell.self
        }
    }
    
    var reuseIdentifier: String {
        switch self {
        case .checkmark: "CheckmarkCell"
        case .arrow: "ArrowCell"
        case .toggle: "ToggleCell"
        case .statistics: "StatisticsCell"
        }
    }
}

final class Table: UITableView {
    
    init(style: TableStyle) {
        super.init(frame: .zero, style: .plain)
        
        self.layer.cornerRadius = 16
        self.separatorStyle = .none
        
        self.register(style.cellType, forCellReuseIdentifier: style.reuseIdentifier)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
}
