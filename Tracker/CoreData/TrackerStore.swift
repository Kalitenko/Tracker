import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidChange()
}

final class TrackerStore: NSObject {
    
    // MARK: Properties
    weak var delegate: TrackerCategoryStoreDelegate?
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(TrackerCoreData.name), ascending: true)]
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
    
    func add(_ tracker: Tracker, to category: TrackerCategoryCoreData) throws -> Tracker {
        let trackerCoreData = TrackerCoreData(context: context)
        updateExisting(trackerCoreData, with: tracker)
        trackerCoreData.category = category
        try context.save()
        
        return try EntityMapper.convertToTracker(trackerCoreData)
    }
    
    func updateExisting(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.name = tracker.name
        trackerCoreData.schedule = tracker.schedule as NSObject
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Logger.info("Таблица трекеров обновлена")
    }
}
