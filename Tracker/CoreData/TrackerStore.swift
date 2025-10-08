import UIKit
import CoreData

final class TrackerStore {
    private let context: NSManagedObjectContext

    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func add(_ tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        updateExisting(trackerCoreData, with: tracker)
        try context.save()
    }
    
    func updateExisting(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.schedule = tracker.schedule as NSObject
    }
}
