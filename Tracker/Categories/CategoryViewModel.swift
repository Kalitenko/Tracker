final class CategoryViewModel {
    
    // MARK: - Constants
    private enum Constants {
        static let limitSymbolsNumber = 38
        static let limitText = "Ограничение \(limitSymbolsNumber) символов"
        static let alreadyExistsText = "Категория с таким названием уже существует"
    }
    
    // MARK: - Public Properties
    var onValidationChanged: Binding<Bool>?
    var onValidationError: Binding<String?>?
    
    // MARK: - Private Properties
    private let dataProvider: DataProvider = .shared
    private let mode: Mode
    private let currentCategory: TrackerCategory?
    
    private var title: String = "" {
        didSet {
            trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            validateTitle()
        }
    }
    private var trimmedTitle: String = ""
    
    // MARK: - Initializers
    init(mode: Mode) {
        self.mode = mode
        switch mode {
        case .create:
            currentCategory = nil
        case .edit(let category):
            currentCategory = category
            title = category.title
            trimmedTitle = category.title
        }
    }
    
    // MARK: - Public Methods
    func didChangeName(_ text: String) {
        title = text
    }
    
    func didTapButton() {
        guard !trimmedTitle.isEmpty else { return }
        switch mode {
        case .create:
            createNewCategory()
        case .edit(let category):
            guard trimmedTitle != category.title else { return }
            updateTitle(for: category, newTitle: trimmedTitle)
        }
    }
    
    // MARK: - Private Methods
    private func validateTitle() {
        if trimmedTitle.count > Constants.limitSymbolsNumber {
            onValidationError?(Constants.limitText)
            onValidationChanged?(false)
            return
        }
        
        if isExistCategory() && trimmedTitle != currentCategory?.title {
            onValidationError?(Constants.alreadyExistsText)
            onValidationChanged?(false)
            return
        }
        
        onValidationError?(nil)
        onValidationChanged?(!trimmedTitle.isEmpty)
    }
    
    private func isExistCategory() -> Bool {
        dataProvider.isExistCategory(withTitle: trimmedTitle)
    }
    
    private func createNewCategory() {
        dataProvider.createCategory(withTitle: trimmedTitle)
    }
    
    private func updateTitle(for category: TrackerCategory, newTitle: String) {
        dataProvider.updateCategory(category: category, withNewTitle: newTitle)
    }
}
