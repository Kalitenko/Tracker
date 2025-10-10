import UIKit

protocol DataProviderProtocol {
    var categories: [TrackerCategory] { get }
    var completedTrackers: [TrackerRecord] { get }
}

protocol DataProviderDelegate: AnyObject {
    func didUpdateCategories()
    func didUpdateRecords()
}

final class DataProvider: DataProviderProtocol {
    
    // MARK: - Shared Instance
    static let shared = DataProvider()
    
    weak var delegate: DataProviderDelegate?
    
    private let categoryStore: TrackerCategoryStore
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    
    private init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        categoryStore = TrackerCategoryStore(context: context)
        trackerStore = TrackerStore(context: context)
        recordStore = TrackerRecordStore(context: context)
    }
    
    lazy var categories: [TrackerCategory] = {
        (try? categoryStore.fetchCategories()) ?? []
    }()
    
    lazy var completedTrackers: [TrackerRecord] = {
        (try? recordStore.fetchRecords()) ?? []
    }()
    
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
    
    func createTracker(_ tracker: Tracker, to categoryTitle: String) {
        
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
