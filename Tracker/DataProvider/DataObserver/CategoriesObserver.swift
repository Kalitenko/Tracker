import Foundation

protocol CategoriesObserverDelegate: AnyObject {
    func didUpdateCategories(_ changes: [DataChange])
}

final class CategoriesObserver {
    // MARK: - Public Properties
    weak var delegate: CategoriesObserverDelegate?
    
    // MARK: - Private Properties
    private let categoryStore: TrackerCategoryStore
    
    // MARK: - Initializers
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        categoryStore.delegate = self
    }
}

extension CategoriesObserver: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidChange(_ changes: [DataChange]) {
        delegate?.didUpdateCategories(changes)
    }
}
