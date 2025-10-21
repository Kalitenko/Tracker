final class CategoryListViewModel {
    
    // MARK: - Public Properties
    var onCategoriesChanged: Binding<[TrackerCategory]>?
    var onEmptyStateChanged: Binding<Bool>?
    var onSelectionChanged: Binding<TrackerCategory?>?
    var onCategoriesChangedWithChanges: Binding<([TrackerCategory], [DataChange])>?
    
    // MARK: - Private Properties
    private(set) var categories: [TrackerCategory] = []
    private(set) var selectedCategory: TrackerCategory?
    private let dataProvider: DataProvider = DataProvider.shared
    private let dataObserver: CategoriesObserver = DataProvider.shared.categoriesObserver
    
    // MARK: - Initializers
    init() {
        dataObserver.delegate = self
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

extension CategoryListViewModel: CategoriesObserverDelegate {
    func didUpdateCategories(_ changes: [DataChange]) {
        categories = dataProvider.categories
        onCategoriesChangedWithChanges?((categories, changes))
        onEmptyStateChanged?(categories.isEmpty)
    }
}
