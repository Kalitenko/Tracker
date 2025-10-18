final class CategoryListViewModel {
    
    // MARK: - Public Properties
    var onCategoriesChanged: Binding<[TrackerCategory]>?
    var onEmptyStateChanged: Binding<Bool>?
    var onSelectionChanged: Binding<TrackerCategory?>?
    
    // MARK: - Private Properties
    private(set) var categories: [TrackerCategory] = []
    private(set) var selectedCategory: TrackerCategory?
    private let dataProvider: DataProvider = DataProvider.shared
    private let dataObserver: CategoriesObserver = DataProvider.shared.categoriesObserver
    
    // MARK: - Initializers
    init() {
        
    }
    
    // MARK: - Public Methods
    func loadCategories() {
        categories = dataProvider.categories
        notifyState()
    }
    
    func selectCategory(at index: Int) {
        guard index < categories.count else { return }
        selectedCategory = categories[index]
        onSelectionChanged?(selectedCategory)
    }
    
    // MARK: - Private Methods
    private func notifyState() {
        onCategoriesChanged?(categories)
        onEmptyStateChanged?(categories.isEmpty)
    }
    
}
