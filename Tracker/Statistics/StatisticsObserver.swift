import Foundation

protocol StatisticsObserverDelegate: AnyObject {
    func didUpdateStatistics()
}

protocol StatisticsObserverProtocol: AnyObject {
    var delegate: StatisticsObserverDelegate? { get set }
}

final class StatisticsObserver {
    
    // MARK: - Shared Instance
    static let shared = StatisticsObserver()
    
    // MARK: - Public Properties
    weak var delegate: StatisticsObserverDelegate?
    
    // MARK: - Private Properties
    private let recordStore: TrackerRecordStore
    
    // MARK: - Initializers
    init() {
        let context = DataBaseStore.shared.persistentContainer.viewContext
        recordStore = TrackerRecordStore(context: context)
        recordStore.delegate = self
    }
}

extension StatisticsObserver: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChange(record: TrackerRecord, changeType: DataChangeType) {
        delegate?.didUpdateStatistics()
    }
}

extension StatisticsObserver: StatisticsObserverProtocol {}
