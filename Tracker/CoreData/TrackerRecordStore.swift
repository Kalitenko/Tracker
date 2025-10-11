import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStoreDidChange()
}

final class TrackerRecordStore: NSObject {
    
    // MARK: Properties
    weak var delegate: TrackerRecordStoreDelegate?
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(TrackerRecordCoreData.trackerID), ascending: true)]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        return controller
    }()
    
    // MARK: - Init
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        performFetch()
    }
    
    private func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            Logger.error("Ошибка выполнения performFetch: \(error)")
        }
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
        Logger.debug("trackerRecordCoreData: \(trackerRecordCoreData)")
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

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerRecordStoreDidChange()
    }
}
