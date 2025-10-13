import Foundation

protocol DataObserverDelegate: AnyObject {
    func didUpdateTrackers(_ changes: [DataChange])
    func didUpdateCategories()
    func didUpdateRecords()
}

enum DataChange {
    case insert(IndexPath)
    case delete(IndexPath)
    case update(IndexPath)
    case move(from: IndexPath, to: IndexPath)
    case insertSection(Int)
    case deleteSection(Int)
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
    func trackerStoreDidChange(_ changes: [DataChange]) {
        delegate?.didUpdateTrackers(changes)
    }
    

    
//    func trackerStoreDidChange() {
//        delegate?.didUpdateTrackers()
//    }
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
