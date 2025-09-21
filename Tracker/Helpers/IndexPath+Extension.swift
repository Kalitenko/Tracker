import UIKit

extension IndexPath {
    func isLastRow(in tableView: UITableView) -> Bool {
        return row == tableView.numberOfRows(inSection: section) - 1
    }
}
