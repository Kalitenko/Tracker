import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidChange(_ changes: [DataChange])
}

final class TrackerStore: NSObject {
    
    // MARK: Properties
    weak var delegate: TrackerStoreDelegate?
     let context: NSManagedObjectContext
     lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCoreData.category.title), ascending: true),
            NSSortDescriptor(key: "id", ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCoreData.category.title),
            cacheName: nil
        )
        controller.delegate = self
        return controller
    }()
    
    
    // MARK: - Init
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    private var pendingChanges: [DataChange] = []
    
    func fetchTrackers(for date: Date) -> [Tracker] {
        guard let dayName = date.dayName() as String? else {
            Logger.error("Не удалось определить день недели")
            return []
        }
        
        fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "daysString CONTAINS %@", dayName
        )
        
        do {
            try fetchedResultsController.performFetch()
            let trackers = fetchedResultsController.fetchedObjects ?? []
            return trackers.compactMap { try? EntityMapper.convertToTracker($0) }
        } catch {
            Logger.error("Ошибка при выполнении запроса трекеров: \(error)")
            return []
        }
    }
    
    func fetchTrackersGroupedByCategory(for date: Date) -> [TrackerCategory] {
        guard let dayName = date.dayName() as String? else {
            Logger.error("Не удалось определить день недели")
            return []
        }

        fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "%K CONTAINS %@", #keyPath(TrackerCoreData.daysString), dayName
        )
        
        do {
            try fetchedResultsController.performFetch()
            guard let frcSections = fetchedResultsController.sections else { return [] }

            var categories: [TrackerCategory] = []

            for sectionInfo in frcSections {
                let objects = sectionInfo.objects as? [TrackerCoreData] ?? []
                let trackers = objects.compactMap { try? EntityMapper.convertToTracker($0) }
                let sectionName = sectionInfo.name
                categories.append(TrackerCategory(title: sectionName, trackers: trackers))
            }
            return categories
        } catch {
            Logger.error("Ошибка при выполнении запроса трекеров: \(error)")
            return []
        }
    }
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItems(in section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return try? EntityMapper.convertToTracker(trackerCoreData)
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
        trackerCoreData.daysString = tracker.schedule.map(\.rawValue).joined(separator: ",")
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
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
        delegate?.trackerStoreDidChange(pendingChanges)
        Logger.info("Обновления трекеров: \(pendingChanges.count) изменений")
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
