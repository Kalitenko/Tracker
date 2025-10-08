import UIKit
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext

    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func add(_ record: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        updateExisting(trackerRecordCoreData, with: record)
        try context.save()
    }
    
    func updateExisting(_ trackerRecordCoreData: TrackerRecordCoreData, with record: TrackerRecord) {
        trackerRecordCoreData.trackerID = record.trackerId
        trackerRecordCoreData.date = record.date
    }
}
