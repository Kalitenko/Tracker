import Foundation

protocol TrackersObserverDelegate: AnyObject {
    func didUpdateTrackers(_ changes: [DataChange])
    func didUpdateRecords(record: TrackerRecord, changeType: DataChangeType)
}

final class TrackersObserver {
    // MARK: - Public Properties
    weak var delegate: TrackersObserverDelegate?
    
    // MARK: - Private Properties
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    
    // MARK: - Initializers
    init(trackerStore: TrackerStore,
         recordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        
        setupObservers()
    }
    
    // MARK: - Private Methods
    private func setupObservers() {
        trackerStore.delegate = self
        recordStore.delegate = self
    }
}

extension TrackersObserver: TrackerStoreDelegate {
    func trackerStoreDidChange(_ changes: [DataChange]) {
        delegate?.didUpdateTrackers(changes)
    }
}

extension TrackersObserver: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChange(record: TrackerRecord, changeType: DataChangeType) {
        delegate?.didUpdateRecords(record: record, changeType: changeType)
    }
}
