protocol DataObserverDelegate: AnyObject {
    func didUpdateTrackers()
    func didUpdateCategories()
    func didUpdateRecords()
}

final class DataObserver {
    weak var delegate: DataObserverDelegate?
    
    private let categoryStore: TrackerCategoryStore
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    
    init(categoryStore: TrackerCategoryStore,
         trackerStore: TrackerStore,
         recordStore: TrackerRecordStore) {
        self.categoryStore = categoryStore
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        
        setupObservers()
    }
    
    private func setupObservers() {
        categoryStore.delegate = self
        trackerStore.delegate = self
        recordStore.delegate = self
    }
}

extension DataObserver: TrackerStoreDelegate {
    func trackerStoreDidChange() {
        delegate?.didUpdateTrackers()
    }
}

extension DataObserver: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidChange() {
        delegate?.didUpdateCategories()
    }
}

extension DataObserver: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChange() {
        delegate?.didUpdateRecords()
    }
}
