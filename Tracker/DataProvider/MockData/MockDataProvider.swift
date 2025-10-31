import Foundation

final class MockDataProvider: DataProviderProtocol {
    
    // MARK: - Shared Instance
    static let shared = MockDataProvider()
    
    // MARK: - Public Properties
    let categories: [TrackerCategory]
    let completedTrackers: [TrackerRecord]
    
    // MARK: - Initializer
    private init() {
        self.categories = MockDataProvider.makeCategories()
        self.completedTrackers = MockDataProvider.makeCompletedTrackers()
    }
    
    func createTracker(_ tracker: Tracker, to categoryTitle: String) {}
    func addRecord(_ record: TrackerRecord) {}
    func deleteRecord(_ record: TrackerRecord) {}
    func updateTracker(_ tracker: Tracker, to categoryTitle: String) {}
    func deleteTracker(_ tracker: Tracker) {}
}


// MARK: - Mock data
private extension MockDataProvider {
    
    private static func makeCategories() -> [TrackerCategory] {
        let workTrackers = TrackerCategory(
            title: "Работа",
            trackers: [
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
        )
        
        let healthTrackers = TrackerCategory(
            title: "Здоровье",
            trackers: [
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
        )
        
        let hobbyTrackers = TrackerCategory(
            title: "Хобби",
            trackers: [
                Tracker(
                    id: 301,
                    name: "Играть на гитаре",
                    color: .systemRed,
                    emoji: "🎸",
                    schedule: [.sunday]
                )
            ]
        )
        
        return [workTrackers, healthTrackers, hobbyTrackers]
    }
    
    private static func makeCompletedTrackers() -> [TrackerRecord] {
        let today = Date()
        let calendar = Calendar.current
        
        return [
            TrackerRecord(trackerId: 101, date: today),
            TrackerRecord(trackerId: 101, date: calendar.date(byAdding: .day, value: -1, to: today)!),
            TrackerRecord(trackerId: 101, date: calendar.date(byAdding: .day, value: -2, to: today)!),
            
            TrackerRecord(trackerId: 102, date: today),
            TrackerRecord(trackerId: 103, date: today)
        ]
    }
}
