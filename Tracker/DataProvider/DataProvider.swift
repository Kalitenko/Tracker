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
    
    // MARK: - Public Properties
    var trackersObserver: TrackersObserver
    var categoriesObserver: CategoriesObserver
    
    // MARK: - Private Properties
    private let categoryStore: TrackerCategoryStore
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    
    // MARK: - Initializers
    private init() {
        let context = DataBaseStore.shared.persistentContainer.viewContext
        categoryStore = TrackerCategoryStore(context: context)
        trackerStore = TrackerStore(context: context)
        recordStore = TrackerRecordStore(context: context)
        
        trackersObserver = TrackersObserver(
            trackerStore: trackerStore,
            recordStore: recordStore
        )
        
        categoriesObserver = CategoriesObserver(
            categoryStore: categoryStore
        )
    }
    
    // MARK: - Public Methods
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
    
    func trackers(for date: Date) -> [Tracker] {
        trackerStore.fetchTrackers(for: date)
    }
    
    func categories(for date: Date) -> [TrackerCategory] {
        trackerStore.fetchTrackersGroupedByCategory(for: date)
    }
    
    func isExistCategory(withTitle title: String) -> Bool {
        do {
            return try categoryStore.isExist(byTitle: title)
        } catch {
            Logger.error("Ошибка проверки категории: \(error)")
        }
        return false
    }
    
    func createCategory(withTitle title: String) {
        do {
            try categoryStore.add(TrackerCategory(title: title, trackers: []))
            Logger.debug("Создание категории \(title)")
        } catch {
            Logger.error("Ошибка создания категории: \(error)")
        }
    }
    
    func updateCategory(category: TrackerCategory, withNewTitle title: String) {
        do {
            try categoryStore.update(category: category, withNewTitle: title)
            Logger.debug("Обновление названия категории с \(category.title) на \(title)")
        } catch {
            Logger.error("Ошибка обновления названия категории: \(error)")
        }
    }
    
    func deleteCategory(_ category: TrackerCategory) {
        do {
            try categoryStore.delete(category: category)
            Logger.debug("Удаление категории \(category.title)")
        } catch {
            Logger.error("Ошибка удаления категории: \(error)")
        }
    }
    
}

// MARK: - DataProviderProtocol
extension DataProvider: DataProviderProtocol {
    var categories: [TrackerCategory] {
        (try? categoryStore.fetchCategories()) ?? []
    }
    
    var completedTrackers: [TrackerRecord] {
        (try? recordStore.fetchRecords()) ?? []
    }
    
    func createTracker(_ tracker: Tracker, to categoryTitle: String) {
        addTracker(tracker, to: categoryTitle)
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
