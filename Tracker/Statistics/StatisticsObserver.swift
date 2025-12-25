import Foundation

protocol StatisticsObserverDelegate: AnyObject {
    func calculateStatistics()
    func calculateIdealDays()
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
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    
    // MARK: - Initializers
    init() {
        let context = DataBaseStore.shared.persistentContainer.viewContext
        recordStore = TrackerRecordStore(context: context)
        trackerStore = TrackerStore(context: context)
        categoryStore = TrackerCategoryStore(context: context)
        recordStore.delegate = self
        trackerStore.statisticsDelegate = self
        categoryStore.delegate = self
        
    }
}

extension StatisticsObserver: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChange(record: TrackerRecord, changeType: DataChangeType) {
        delegate?.calculateStatistics()
    }
}

extension StatisticsObserver: TrackerStoreStatisticsDelegate {
    func recalculateIdealDays() {
        delegate?.calculateIdealDays()
    }
}

extension StatisticsObserver: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidChange(_ changes: [DataChange]) {
        let containsDelete = changes.contains {
            if case .delete = $0 {
                true
            } else {
                false
            }
        }
        if containsDelete {
            delegate?.calculateStatistics()
            Logger.debug("Пересчет статистики при удалении категории")
        }
    }
}

extension StatisticsObserver: StatisticsObserverProtocol {}
