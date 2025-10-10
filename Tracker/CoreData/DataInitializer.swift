import CoreData

final class DataInitializer {
    
    private let categoryStore: TrackerCategoryStore

    init(context: NSManagedObjectContext) {
        self.categoryStore = TrackerCategoryStore(context: context)
    }

    func preloadDataIfNeeded() {
        do {
            let existing = try categoryStore.fetchAll()
            if existing.isEmpty {
                try categoryStore.add(TrackerCategory(title: "Важное", trackers: []))
                try categoryStore.add(TrackerCategory(title: "Работа", trackers: []))
                try categoryStore.add(TrackerCategory(title: "Хобби", trackers: []))
                Logger.success("Добавлены начальные категории")
            }
        } catch {
            Logger.error("Не удалось добавить начальные категории: \(error)")
        }
    }
}
