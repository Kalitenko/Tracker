import UIKit

final class TrackerViewModel {
    
    // MARK: - Constants
    private enum Constants {
        static let limitSymbolsNumber = 38
        static let limitText = Utils.symbolCountString(for: limitSymbolsNumber)
    }
    
    // MARK: - Public Properties
    var onValidationChanged: Binding<Bool>?
    var onValidationError: Binding<String?>?
    var options: [String]
    var onScheduleChanged: Binding<[WeekDay]>?
    var onCategoryChanged: Binding<TrackerCategory?>?
    
    // MARK: - Private Properties
    private let mode: TrackerMode
    private let trackerType: TrackerType
    private let dataProvider: DataProviderProtocol = DataProvider.shared
    private var selectedCategory: TrackerCategory? {
        didSet {
            updateActionButtonState()
            onCategoryChanged?(selectedCategory)
        }
    }
    private var selectedEmoji: String? {
        didSet { updateActionButtonState() }
    }
    private var selectedColor: UIColor? {
        didSet { updateActionButtonState() }
    }
    private var selectedDays: [WeekDay] = [] {
        didSet {
            updateActionButtonState()
            onScheduleChanged?(selectedDays)
        }
    }
    private var isNameValid: Bool = false {
        didSet { updateActionButtonState() }
    }
    private var name: String = "" {
        didSet {
            trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            validateName()
        }
    }
    private var trimmedName: String = ""
    private var trackerForUpdate: Tracker?
    
    // MARK: - Initializers
    init(mode: TrackerMode, category: TrackerCategory?, schedule: [WeekDay]) {
        self.mode = mode
        trackerType = mode.trackerType
        options = trackerType.options
        switch mode {
        case .create:
            selectedCategory = category
            selectedDays = schedule
        case .edit(let type, let tracker, let category, let count):
            trackerForUpdate = tracker
            break
        }
        
    }
    
    // MARK: - Public Methods
    func didChangeName(_ text: String) {
        name = text
    }
    
    func createTracker() {
        guard let tracker = prepareTracker() else {
            Logger.error("Ошибка при подготовке трекера к сохранению")
            return
        }
        guard let categoryName = selectedCategory?.title else { return }
        createTracker(tracker, to: categoryName)
    }
    
    func updateTracker() {
        guard let tracker = prepareTrackerForUpdate() else {
            Logger.error("Ошибка при подготовке трекера к обновлению")
            return
        }
        guard let categoryName = selectedCategory?.title else { return }
        updateTracker(tracker, to: categoryName)
    }
    
    func selectEmoji(_ emoji: String) {
        selectedEmoji = emoji
    }
    
    func selectColor(_ color: UIColor) {
        selectedColor = color
    }
    
    func selectCategory(_ category: TrackerCategory) {
        selectedCategory = category
    }
    
    func selectDays(_ days: [WeekDay]) {
        selectedDays = days
    }
    
    func initData() {
        switch mode {
        case .create: break
        case .edit(_, let tracker, let category, let count):
            name = tracker.name
            selectedCategory = category
            selectEmoji(tracker.emoji)
            selectedColor = tracker.color
            selectedDays = tracker.schedule
        }
        
        updateActionButtonState()
    }
    
    // MARK: - Private Methods
    private func updateActionButtonState() {
        let isValid = isNameValid &&
        selectedCategory != nil &&
        selectedEmoji != nil &&
        selectedColor != nil &&
        !(trackerType == .habit && selectedDays.isEmpty)
        
        onValidationChanged?(isValid)
    }
    
    private func createTracker(_ tracker: Tracker, to categoryTitle: String) {
        dataProvider.createTracker(tracker, to: categoryTitle)
    }
    
    private func updateTracker(_ tracker: Tracker, to categoryTitle: String) {
        dataProvider.updateTracker(tracker, to: categoryTitle)
    }
    
    private func prepareTracker() -> Tracker? {
        if trackerType == .habit && selectedDays.isEmpty { return nil }
        let schedule = trackerType == .habit ? selectedDays : WeekDay.allCases
        guard let emoji = selectedEmoji, let color = selectedColor else { return nil }
        
        return Tracker(name: trimmedName, color: color, emoji: emoji, schedule: schedule)
    }
    
    private func prepareTrackerForUpdate() -> Tracker? {
        if trackerType == .habit && selectedDays.isEmpty { return nil }
        let schedule = trackerType == .habit ? selectedDays : WeekDay.allCases
        guard let emoji = selectedEmoji, let color = selectedColor, let trackerId = trackerForUpdate?.id else { return nil }
        
        return Tracker(id: trackerId, name: trimmedName, color: color, emoji: emoji, schedule: schedule)
    }
    
    private func validateName() {
        if trimmedName.count > Constants.limitSymbolsNumber {
            onValidationError?(Constants.limitText)
            onValidationChanged?(false)
            return
        }
        
        onValidationError?(nil)
        isNameValid = !trimmedName.isEmpty
        updateActionButtonState()
    }
}
