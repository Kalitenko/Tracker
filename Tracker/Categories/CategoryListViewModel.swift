final class CategoryListViewModel {
    
    // MARK: - Public Properties
    var onCategoriesChanged: Binding<[TrackerCategory]>?
    var onEmptyStateChanged: Binding<EmptyStateViewType?>?
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
    
    func deleteCategory(_ category: TrackerCategory) {
        dataProvider.deleteCategory(category)
    }
    
    // MARK: - Private Methods
    private func notifyState() {
        onCategoriesChanged?(categories)
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        let type = categories.isEmpty ? EmptyStateViewType.categories : nil
        onEmptyStateChanged?(type)
    }
}

extension CategoryListViewModel: CategoriesObserverDelegate {
    func didUpdateCategories(_ changes: [DataChange]) {
        categories = dataProvider.categories
        onCategoriesChangedWithChanges?((categories, changes))
        updateEmptyState()
    }
}
