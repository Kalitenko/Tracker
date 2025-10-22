import UIKit

final class AlertHelper {
    
    enum Constants {
        static let deleteText = "Удалить"
        static let cancelText = "Отменить"
    }
    
    static func showDeleteConfirmation(
        from viewController: UIViewController,
        message: String,
        deleteAction: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .actionSheet
        )
        
        let delete = UIAlertAction(
            title: Constants.deleteText,
            style: .destructive
        ) { _ in
            deleteAction()
        }
        
        let cancel = UIAlertAction(
            title: Constants.cancelText,
            style: .cancel
        )
        
        alert.addAction(delete)
        alert.addAction(cancel)
        
        viewController.present(alert, animated: true)
    }
}
