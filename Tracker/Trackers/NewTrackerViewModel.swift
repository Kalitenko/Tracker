import UIKit

final class NewTrackerViewModel {
    
    // MARK: - Constants
    private enum Constants {
        static let limitSymbolsNumber = 38
        static let limitText = "Ограничение \(limitSymbolsNumber) символов"
    }
    
    // MARK: - Public Properties
    var onValidationChanged: Binding<Bool>?
    var onValidationError: Binding<String?>?
    var options: [String]
    var onScheduleChanged: Binding<[WeekDay]>?
    var onCategoryChanged: Binding<TrackerCategory?>?
    
    // MARK: - Private Properties
    private let trackerType: TrackerType
    private let dataProvider: DataProviderProtocol = DataProvider.shared
    private var selectedCategory: TrackerCategory? {
        didSet {
            updateCreateButtonState()
            onCategoryChanged?(selectedCategory)
        }
    }
    private var selectedEmoji: String? {
        didSet { updateCreateButtonState() }
    }
    private var selectedColor: UIColor? {
        didSet { updateCreateButtonState() }
    }
    private var selectedDays: [WeekDay] = [] {
        didSet {
            updateCreateButtonState()
            onScheduleChanged?(selectedDays)
        }
    }
    private var isNameValid: Bool = false {
        didSet { updateCreateButtonState() }
    }
    private var name: String = "" {
        didSet {
            trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            validateName()
        }
    }
    private var trimmedName: String = ""
    
    // MARK: - Initializers
    init(trackerType: TrackerType, category: TrackerCategory?, schedule: [WeekDay]) {
        self.trackerType = trackerType
        options = trackerType.options
        selectedCategory = category
        selectedDays = schedule
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
    
    // MARK: - Private Methods
    private func updateCreateButtonState() {
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
    
    private func prepareTracker() -> Tracker? {
        if trackerType == .habit && selectedDays.isEmpty { return nil }
        let schedule = trackerType == .habit ? selectedDays : WeekDay.allCases
        guard let emoji = selectedEmoji, let color = selectedColor else { return nil }
        
        return Tracker(name: trimmedName, color: color, emoji: emoji, schedule: schedule)
    }
    
    private func validateName() {
        if trimmedName.count > Constants.limitSymbolsNumber {
            onValidationError?(Constants.limitText)
            onValidationChanged?(false)
            return
        }
        
        onValidationError?(nil)
        isNameValid = !trimmedName.isEmpty
        updateCreateButtonState()
    }
}
