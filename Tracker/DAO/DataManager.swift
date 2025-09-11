protocol DataManager {
    var categories: [TrackerCategory] { get }
    var completedTrackers: [TrackerRecord] { get }
}
