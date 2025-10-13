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
                
                try categoryStore.add(TrackerCategory(title: "Важное", trackers: []))
                try categoryStore.add(TrackerCategory(title: "Работа", trackers: workTrackers))
                try categoryStore.add(TrackerCategory(title: "Здоровье", trackers: healthTrackers))
                try categoryStore.add(TrackerCategory(title: "Хобби", trackers: hobbyTrackers))
                Logger.success("Добавлены начальные категории")
            }
        } catch {
            Logger.error("Не удалось добавить начальные категории: \(error)")
        }
    }
}
