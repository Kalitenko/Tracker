import CoreData

final class DataInitializer {
    
    // MARK: - Private Properties
    private let categoryStore: TrackerCategoryStore
    private let trackerStore: TrackerStore
    
    // MARK: - Initializers
    init(context: NSManagedObjectContext) {
        self.categoryStore = TrackerCategoryStore(context: context)
        self.trackerStore = TrackerStore(context: context)
    }
    
    // MARK: - Public Methods
    func preloadDataIfNeeded() {
        do {
            let existing = try categoryStore.fetchAll()
            guard existing.isEmpty else {
                Logger.success("Начальные данные уже существуют, пропускаем")
                return
            }
            
            let categories = [
                TrackerCategory(title: "Важное", trackers: []),
                TrackerCategory(title: "Работа", trackers: []),
                TrackerCategory(title: "Здоровье", trackers: []),
                TrackerCategory(title: "Хобби", trackers: [])
            ]
            
            for category in categories {
                try categoryStore.add(category)
            }
            
            Logger.success("Категории добавлены")
            
            let workTrackers = [
                Tracker(
                    id: 101,
                    name: "Утренняя планёрка",
                    color: .systemBlue,
                    emoji: "📋",
                    schedule: [.monday, .wednesday, .friday]
                ),
                Tracker(
                    id: 102,
                    name: "Проверка почты",
                    color: .systemTeal,
                    emoji: "📧",
                    schedule: [.monday, .tuesday, .wednesday, .thursday, .friday]
                ),
                Tracker(
                    id: 103,
                    name: "Код-ревью",
                    color: .systemOrange,
                    emoji: "💻",
                    schedule: [.monday, .thursday]
                )
            ]
            
            let healthTrackers = [
                Tracker(
                    id: 201,
                    name: "Утренняя пробежка",
                    color: .systemGreen,
                    emoji: "🏃‍♂️",
                    schedule: [.monday, .wednesday, .friday, .sunday]
                ),
                Tracker(
                    id: 202,
                    name: "Медитация",
                    color: .systemPurple,
                    emoji: "🧘‍♀️",
                    schedule: [.wednesday, .sunday]
                )
            ]
            
            let hobbyTrackers = [
                Tracker(
                    id: 301,
                    name: "Играть на гитаре",
                    color: .systemRed,
                    emoji: "🎸",
                    schedule: [.sunday]
                )
            ]
            
            try addTrackers(workTrackers, toCategoryNamed: "Работа")
            try addTrackers(healthTrackers, toCategoryNamed: "Здоровье")
            try addTrackers(hobbyTrackers, toCategoryNamed: "Хобби")
            
            Logger.success("✅ Добавлены начальные категории и трекеры")
            
        } catch {
            Logger.error("❌ Не удалось добавить начальные категории: \(error)")
        }
    }
    
    // MARK: - Private Methods
    private func addTrackers(_ trackers: [Tracker], toCategoryNamed categoryName: String) throws {
        for tracker in trackers {
            try trackerStore.add(tracker, toCategoryNamed: categoryName)
        }
    }
}
