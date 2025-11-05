import Foundation
import CoreData

extension TrackerCoreData {
    @objc var groupTitle: String {
        if isPinned {
            return L10n.pinned
        } else {
            return category?.title ?? L10n.withoutCategory
        }
    }
}
