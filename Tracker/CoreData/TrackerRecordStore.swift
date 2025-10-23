import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStoreDidChange(record: TrackerRecord, changeType: DataChangeType)
}

final class TrackerRecordStore: NSObject {
    
    // MARK: - Public Properties
    weak var delegate: TrackerRecordStoreDelegate?
    
    // MARK: - Private Properties
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
    
    // MARK: - Initializers
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        performFetch()
    }
    
    // MARK: - Public Methods
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
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(TrackerRecordCoreData.trackerID), ascending: true)]
        
        let objects = try context.fetch(fetchRequest)
        let records = try objects.map(EntityMapper.convertToTrackerRecord)
        
        return records
    }
    
    func fetchRecords(ids: [Int32]) throws -> [TrackerRecord] {
        guard !ids.isEmpty else { return [] }
        
        fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "%K IN %@", #keyPath(TrackerRecordCoreData.trackerID), ids
        )
        
        try fetchedResultsController.performFetch()
        
        let objects = fetchedResultsController.fetchedObjects ?? []
        let records = try objects.map(EntityMapper.convertToTrackerRecord)
        
        return records
    }
    
    // MARK: - Private Methods
    private func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            Logger.error("Ошибка выполнения performFetch: \(error)")
        }
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard let entity = anObject as? TrackerRecordCoreData else { return }
        
        do {
            let record = try EntityMapper.convertToTrackerRecord(entity)
            
            switch type {
            case .insert:
                delegate?.trackerRecordStoreDidChange(record: record, changeType: .insert)
            case .delete:
                delegate?.trackerRecordStoreDidChange(record: record, changeType: .delete)
            case .update:
                delegate?.trackerRecordStoreDidChange(record: record, changeType: .update)
            case .move:
                delegate?.trackerRecordStoreDidChange(record: record, changeType: .move(from: indexPath, to: newIndexPath))
            @unknown default:
                break
            }
        } catch {
            Logger.error("Не удалось конвертировать TrackerRecordCoreData в TrackerRecord: \(error)")
        }
    }
}
