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
    
    func deleteEntity(_ entity: TrackerRecordCoreData) throws {
        context.delete(entity)
        try context.save()
    }
    
    func delete(_ record: TrackerRecord) throws {
        let trackerRecordCoreData = try fetch(byTrackerId: record.trackerId, date: record.date)
        try deleteEntity(trackerRecordCoreData)
    }
    
    func fetch(byTrackerId trackerId: Int32, date: Date) throws -> TrackerRecordCoreData {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()

        let trackerPredicate = NSPredicate(format: "%K == %d", #keyPath(TrackerRecordCoreData.trackerID), trackerId)
        let datePredicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.date), date as NSDate)

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [trackerPredicate, datePredicate])
        fetchRequest.fetchLimit = 1

        guard let result = try context.fetch(fetchRequest).first else {
            throw NSError(domain: "TrackerRecordStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Record not found"])
        }

        return result
    }
    
    func fetchAll() throws -> [TrackerRecordCoreData] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let coreDataRecords = try context.fetch(fetchRequest)
        
        return coreDataRecords
    }
    
    func fetchRecords() throws -> [TrackerRecord] {
        let categories = try fetchAll().compactMap(EntityMapper.convertToTrackerRecord)
        
        return categories
    }
    
}
