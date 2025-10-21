final class NewCategoryViewModel {
    
    // MARK: - Constants
    private enum Constants {
        static let limitSymbolsNumber = 38
        static let limitText = "Ограничение \(limitSymbolsNumber) символов"
        static let alreadyExistsText = "Категория с таким названием уже существует"
    }
    
    // MARK: - Public Properties
    var onValidationChanged: ((Bool) -> Void)?
    var onValidationError: ((String?) -> Void)?
    
    // MARK: - Private Properties
    private let dataProvider: DataProvider = .shared
    
    private var title: String = "" {
        didSet {
            trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            validateTitle()
        }
    }
    private var trimmedTitle: String = ""
    
    // MARK: - Public Methods
    func didChangeName(_ text: String) {
        title = text
    }
    
    func didTapCreateButton() {
        guard !trimmedTitle.isEmpty else { return }
        createNewCategory()
    }
    
    // MARK: - Private Methods
    private func validateTitle() {
        if trimmedTitle.count > Constants.limitSymbolsNumber {
            onValidationError?(Constants.limitText)
            onValidationChanged?(false)
            return
        }
        
        if isExistCategory() {
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
}
