@testable import Tracker

final class MockCategoryListViewModel: CategoryListViewModelProtocol {
    var onCategoriesChanged: Binding<[TrackerCategory]>?
    var onEmptyStateChanged: Binding<EmptyStateViewType?>?
    var onSelectionChanged: Binding<TrackerCategory?>?
    var onCategoriesChangedWithChanges: Binding<([TrackerCategory], [DataChange])>?

    var categories: [TrackerCategory] = [
        TrackerCategory(title: "Health", trackers: []),
        TrackerCategory(title: "Work", trackers: [])
    ]

    func loadCategories() {
        onCategoriesChanged?(categories)
        onEmptyStateChanged?(categories.isEmpty ? .categories : nil)
    }

    func selectCategory(at index: Int) {
        
    }

    func deleteCategory(_ category: TrackerCategory) {
        categories.removeAll { $0.title == category.title }
    }
}
