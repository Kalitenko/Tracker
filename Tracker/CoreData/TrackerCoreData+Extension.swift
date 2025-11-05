import Foundation
import CoreData

extension TrackerCoreData {
    @objc var groupTitle: String {
        if isPinned {
            return "Закрепленные"
        } else {
            return category?.title ?? "Без категории"
        }
    }
}
