import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidChange(_ changes: [DataChange])
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
    private var pendingChanges: [DataChange] = []
    
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
    
    func isExist(byTitle title: String) throws -> Bool {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K ==[c] %@", #keyPath(TrackerCategoryCoreData.title), title)
        fetchRequest.fetchLimit = 1
        fetchRequest.includesSubentities = false

        let count = try context.count(for: fetchRequest)
        return count > 0
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
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        pendingChanges.removeAll()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                pendingChanges.append(.insert(newIndexPath))
            }
        case .delete:
            if let indexPath = indexPath {
                pendingChanges.append(.delete(indexPath))
            }
        case .update:
            if let indexPath = indexPath {
                pendingChanges.append(.update(indexPath))
            }
        case .move:
            if let from = indexPath, let to = newIndexPath {
                pendingChanges.append(.move(from: from, to: to))
            }
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard !pendingChanges.isEmpty else { return }
        delegate?.trackerCategoryStoreDidChange(pendingChanges)
        Logger.info("Обновления категорий: \(pendingChanges.count) изменений")
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
        switch type {
        case .insert:
            pendingChanges.append(.insertSection(sectionIndex))
        case .delete:
            pendingChanges.append(.deleteSection(sectionIndex))
        default:
            break
        }
    }
}
