import UIKit
import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext

    // MARK: - Init
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func add(_ category: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        updateExisting(trackerCategoryCoreData, with: category)
        try context.save()
    }
    
    func updateExisting(_ trackerCategoryCoreData: TrackerCategoryCoreData, with category: TrackerCategory) {
        trackerCategoryCoreData.title = category.title
    }

}
