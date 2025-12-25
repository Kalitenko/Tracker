import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidChange(_ changes: [DataChange])
}

protocol TrackerStoreStatisticsDelegate: AnyObject {
    func recalculateIdealDays()
}

final class TrackerStore: NSObject {
    
    // MARK: - Public Properties
    weak var delegate: TrackerStoreDelegate?
    weak var statisticsDelegate: TrackerStoreStatisticsDelegate? {
        didSet {
            guard statisticsDelegate != nil else { return }
            do {
                try allTrackersFRC.performFetch()
            } catch {
                Logger.error("Ошибка при fetch allTrackersFRC: \(error)")
            }
        }
    }
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "isPinned", ascending: false),
            NSSortDescriptor(key: #keyPath(TrackerCoreData.category.title), ascending: true),
            NSSortDescriptor(key: "id", ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCoreData.groupTitle),
            cacheName: nil
        )
        controller.delegate = self
        return controller
    }()
    private lazy var allTrackersFRC: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "id", ascending: true)
        ]
        
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
    }
    
    // MARK: - Public Methods
    func fetchTrackers(for date: Date) -> [Tracker] {
        guard let dayName = date.weekDayRawValue as String? else {
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
        guard let dayName = date.weekDayRawValue as String? else {
            Logger.error("Не удалось определить день недели")
            return []
        }
        
        let fetchRequest = fetchedResultsController.fetchRequest
        fetchRequest.predicate = NSPredicate(
            format: "%K CONTAINS %@", #keyPath(TrackerCoreData.daysString), dayName
        )
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "isPinned", ascending: false),
            NSSortDescriptor(key: #keyPath(TrackerCoreData.category.title), ascending: true),
            NSSortDescriptor(key: "id", ascending: true)
        ]
        
        do {
            try fetchedResultsController.performFetch()
            guard let frcSections = fetchedResultsController.sections else { return [] }
            
            var categories: [TrackerCategory] = []
            
            for sectionInfo in frcSections {
                guard let objects = sectionInfo.objects as? [TrackerCoreData] else { continue }
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
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return try? EntityMapper.convertToTracker(trackerCoreData)
    }
    
    @discardableResult
    func add(_ tracker: Tracker, to category: TrackerCategoryCoreData) throws -> Tracker {
        let trackerCoreData = TrackerCoreData(context: context)
        updateExisting(trackerCoreData, with: tracker)
        trackerCoreData.category = category
        try context.save()
        
        return try EntityMapper.convertToTracker(trackerCoreData)
    }
    
    func update(_ tracker: Tracker, to category: TrackerCategoryCoreData) {
        guard let existingTracker = fetchById(tracker.id) else {
            Logger.error("Не найден трекер для обновления с id: \(tracker.id)")
            return
        }
        updateExisting(existingTracker, with: tracker)
        
        if existingTracker.category != category {
            existingTracker.category = category
        }
        
        do {
            try context.save()
            Logger.success("Трекер '\(tracker.name)' успешно обновлён")
        } catch {
            Logger.error("Ошибка при сохранении обновлённого трекера: \(error)")
        }
    }
    
    func update(_ tracker: Tracker) {
        guard let existingTracker = fetchById(tracker.id) else {
            Logger.error("Не найден трекер для обновления с id: \(tracker.id)")
            return
        }
        updateExisting(existingTracker, with: tracker)
        
        do {
            try context.save()
            Logger.success("Трекер '\(tracker.name)' успешно обновлён")
        } catch {
            Logger.error("Ошибка при сохранении обновлённого трекера: \(error)")
        }
    }
    
    func delete(_ tracker: Tracker) throws {
        guard let entity = fetchById(tracker.id) else {
            Logger.error("Невозможно удалить несуществующий трекер")
            return
        }
        context.delete(entity)
        try context.save()
    }
    
    func updateExisting(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.name = tracker.name
        trackerCoreData.schedule = tracker.schedule as NSObject
        trackerCoreData.daysString = tracker.schedule.map(\.rawValue).joined(separator: ",")
        trackerCoreData.isHabit = tracker.isHabit
        trackerCoreData.isPinned = tracker.isPinned
    }
    
    @discardableResult
    func add(_ tracker: Tracker, toCategoryNamed categoryName: String) throws -> Tracker {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), categoryName)
        
        guard let category = try context.fetch(fetchRequest).first else {
            throw NSError(domain: "TrackerStore", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "Категория '\(categoryName)' не найдена"
            ])
        }
        
        let trackerCoreData = TrackerCoreData(context: context)
        updateExisting(trackerCoreData, with: tracker)
        trackerCoreData.category = category
        try context.save()
        
        Logger.success("Добавлен трекер '\(tracker.name)' в категорию '\(categoryName)'")
        return try EntityMapper.convertToTracker(trackerCoreData)
    }
    
    func fetchById(_ id: Int32) -> TrackerCoreData? {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", NSNumber(value: id))
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            Logger.error("Ошибка при поиске трекера по id: \(error)")
            return nil
        }
    }
    
    private func fetchAll() throws -> [TrackerCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        let coreDataTrackers = try context.fetch(fetchRequest)
        
        return coreDataTrackers
    }
    
    func fetchAllTrackers() throws -> [Tracker] {
        let entities = try fetchAll()
        let records = try entities.map(EntityMapper.convertToTracker)
        
        return records
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate
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
        if controller == fetchedResultsController {
            guard !pendingChanges.isEmpty else { return }
            delegate?.trackerStoreDidChange(pendingChanges)
            pendingChanges.removeAll()
            Logger.info("Обновления трекеров: \(pendingChanges.count) изменений")
        } else if controller == allTrackersFRC {
            statisticsDelegate?.recalculateIdealDays()
            Logger.debug("Пересчет идеальных дней")
        }
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
