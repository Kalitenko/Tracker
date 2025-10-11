import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidChange()
}

final class TrackerCategoryStore: NSObject {
    
    // MARK: Properties
    weak var delegate: TrackerCategoryStoreDelegate?
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(TrackerCategoryCoreData.title), ascending: true)]
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
    
    func add(_ category: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        updateExisting(trackerCategoryCoreData, with: category)
        try context.save()
    }
    
    func updateExisting(_ trackerCategoryCoreData: TrackerCategoryCoreData, with category: TrackerCategory) {
        trackerCategoryCoreData.title = category.title

        if !category.trackers.isEmpty {
            let trackersSet = NSSet(array: category.trackers.compactMap { tracker in
                let trackerCoreData = TrackerCoreData(context: context)
                return EntityMapper.convertToTrackerCoreData(tracker: tracker, trackerCoreData: trackerCoreData)
            })
            trackerCategoryCoreData.trackers = trackersSet
        }
    }
    
    func fetchAll() throws -> [TrackerCategoryCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.relationshipKeyPathsForPrefetching = ["trackers"]
                
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(TrackerCategoryCoreData.title), ascending: true)]
        let coreDataCategories = try context.fetch(fetchRequest)
        
        return coreDataCategories
    }
    
    func fetchCategories() throws -> [TrackerCategory] {
        let categories = try fetchAll().compactMap(EntityMapper.convertToTrackerCategory)
        
        Logger.debug("Количество категорий: \(categories.count)")
        return categories
    }
    
    func fetch(byTitle title: String) throws -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), title)
        
        guard let coreDataCategory = try context.fetch(fetchRequest).first else {
            Logger.info("Категорий с таким названием нет")
            return nil
        }
        
        return coreDataCategory
    }

}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerCategoryStoreDidChange()
    }
}
