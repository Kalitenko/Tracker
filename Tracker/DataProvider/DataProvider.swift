import UIKit

protocol DataProviderProtocol {
    var categories: [TrackerCategory] { get }
    var completedTrackers: [TrackerRecord] { get }
    func createTracker(_ tracker: Tracker, to categoryTitle: String)
    func addRecord(_ record: TrackerRecord)
    func deleteRecord(_ record: TrackerRecord)
}

final class DataProvider {
    
    // MARK: - Shared Instance
    static let shared = DataProvider()
    
    var observer: DataObserver
    
    private let categoryStore: TrackerCategoryStore
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    
    private init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        categoryStore = TrackerCategoryStore(context: context)
        trackerStore = TrackerStore(context: context)
        recordStore = TrackerRecordStore(context: context)
        
        observer = DataObserver(
            categoryStore: categoryStore,
            trackerStore: trackerStore,
            recordStore: recordStore
        )
    }
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        do {
            guard let category = try categoryStore.fetch(byTitle: categoryTitle) else {
                Logger.error("Такой категории не существует")
                return
            }
            try trackerStore.add(tracker, to: category)
        } catch {
            Logger.error("Ошибка добавления трекера: \(error)")
        }
    }
   
}

extension DataProvider: DataProviderProtocol {
    var categories: [TrackerCategory] {
        (try? categoryStore.fetchCategories()) ?? []
    }
    
    var completedTrackers: [TrackerRecord] {
        (try? recordStore.fetchRecords()) ?? []
    }
    
    func createTracker(_ tracker: Tracker, to categoryTitle: String) {
        Logger.debug("Создание трекера: \(tracker)")
        let newTracker = addTracker(tracker, to: categoryTitle)
        Logger.debug("Создан трекер: \(newTracker)")
    }
    
    func addRecord(_ record: TrackerRecord) {
        do {
            try recordStore.add(record)
        } catch {
            Logger.error("Ошибка добавления записи: \(error)")
        }
    }
    
    func deleteRecord(_ record: TrackerRecord) {
        do {
            try recordStore.delete(record)
        } catch {
            Logger.error("Ошибка удаления записи: \(error)")
        }
    }
}
