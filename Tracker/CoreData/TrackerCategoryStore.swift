import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidChange()
}

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Public Properties
    weak var delegate: TrackerCategoryStoreDelegate?
    
    // MARK: - Private Properties
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
    
    // MARK: - Initializers
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        performFetch()
    }
    
    // MARK: - Public Methods
    func add(_ category: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        updateExisting(trackerCategoryCoreData, with: category)
        try context.save()
    }

    func fetchAll() throws -> [TrackerCategoryCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.relationshipKeyPathsForPrefetching = ["trackers"]
                
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(TrackerCategoryCoreData.title), ascending: true)]
        let coreDataCategories = try context.fetch(fetchRequest)
        
        return coreDataCategories
    }
    
    func fetchCategoriesOnce() throws -> [TrackerCategory] {
        let coreDataCategories = try fetchAll()
        return try coreDataCategories.compactMap(EntityMapper.convertToTrackerCategory)
    }

    func fetchCategories() throws -> [TrackerCategory] {
        guard let coreDataCategories = fetchedResultsController.fetchedObjects else { return [] }
        return try coreDataCategories.compactMap(EntityMapper.convertToTrackerCategory)
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
    
    // MARK: - Private Methods
    private func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            Logger.error("Ошибка выполнения performFetch: \(error)")
        }
    }
    
    private func updateExisting(_ trackerCategoryCoreData: TrackerCategoryCoreData, with category: TrackerCategory) {
        trackerCategoryCoreData.title = category.title

        if !category.trackers.isEmpty {
            let trackersSet = NSSet(array: category.trackers.compactMap { tracker in
                let trackerCoreData = TrackerCoreData(context: context)
                return EntityMapper.convertToTrackerCoreData(tracker: tracker, trackerCoreData: trackerCoreData)
            })
            trackerCategoryCoreData.trackers = trackersSet
        }
    }

}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerCategoryStoreDidChange()
    }
}
