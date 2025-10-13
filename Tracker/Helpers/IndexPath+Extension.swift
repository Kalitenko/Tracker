import UIKit

extension IndexPath {
    func isLastRow(in tableView: UITableView) -> Bool {
        row == tableView.numberOfRows(inSection: section) - 1
    }
}
