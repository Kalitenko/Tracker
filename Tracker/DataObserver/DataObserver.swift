import Foundation

protocol DataObserverDelegate: AnyObject {
    func didUpdateTrackers(_ changes: [DataChange])
    func didUpdateCategories()
    func didUpdateRecords(record: TrackerRecord, changeType: DataChangeType)
}

enum DataChange {
    case insert(IndexPath)
    case delete(IndexPath)
    case update(IndexPath)
    case move(from: IndexPath, to: IndexPath)
    case insertSection(Int)
    case deleteSection(Int)
}

enum DataChangeType {
    case insert
    case delete
    case update
    case move(from: IndexPath?, to: IndexPath?)
}

final class DataObserver {
    // MARK: - Public Properties
    weak var delegate: DataObserverDelegate?
    
    // MARK: - Private Properties
    private let categoryStore: TrackerCategoryStore
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    
    // MARK: - Initializers
    init(categoryStore: TrackerCategoryStore,
         trackerStore: TrackerStore,
         recordStore: TrackerRecordStore) {
        self.categoryStore = categoryStore
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        
        setupObservers()
    }
    
    // MARK: - Private Methods
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
}

extension DataObserver: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidChange() {
        delegate?.didUpdateCategories()
    }
}

extension DataObserver: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChange(record: TrackerRecord, changeType: DataChangeType) {
        delegate?.didUpdateRecords(record: record, changeType: changeType)
    }
}
