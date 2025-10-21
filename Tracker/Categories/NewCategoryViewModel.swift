final class NewCategoryViewModel {
    
    // MARK: - Public Properties
    var onValidationChanged: ((Bool) -> Void)?
    
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
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        createNewCategory()
    }
    
    // MARK: - Private Methods
    private func validateTitle() {
        let notEmpty = !trimmedTitle.isEmpty
        let doesNotExist = !isExistCategory()
        let isValid = notEmpty && doesNotExist
        onValidationChanged?(isValid)
    }
    
    private func isExistCategory() -> Bool {
        dataProvider.isExistCategory(withTitle: trimmedTitle)
    }
    
    private func createNewCategory() {
        dataProvider.createCategory(withTitle: trimmedTitle)
    }
}
