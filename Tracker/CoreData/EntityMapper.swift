import UIKit

enum EntityMapperError: Error {
    case conversionFailed
}

final class EntityMapper {
    
    static func convertToTrackerCategory(_ entity: TrackerCategoryCoreData) throws -> TrackerCategory? {
        guard let title = entity.title else { throw EntityMapperError.conversionFailed }
        
        let trackersSet = entity.trackers as? Set<TrackerCoreData> ?? []
        let trackers = trackersSet.compactMap { trackerEntity in
                do {
                    return try convertToTracker(trackerEntity)
                } catch {
                    Logger.warning("Ошибка при конвертации сущности трекеса с id=\(trackerEntity.id). Error: \(error)")
                    return nil
                }
            }
        
        return TrackerCategory(title: title, trackers: trackers)
    }
    
    static func convertToTracker(_ entity: TrackerCoreData) throws -> Tracker {
        guard let name = entity.name,
              let color = entity.color as? UIColor,
              let emoji = entity.emoji,
              let schedule = entity.schedule as? [Day] else {
            throw EntityMapperError.conversionFailed
        }
        let id = entity.id
        
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
    
    static func convertToTrackerRecord(_ entity: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let date = entity.date else {
            throw EntityMapperError.conversionFailed
        }
        let trackerId = entity.trackerID
        
        return TrackerRecord(trackerId: trackerId, date: date)
    }
    
    static func convertToTrackerCoreData(tracker: Tracker,
                                         trackerCoreData: TrackerCoreData) -> TrackerCoreData {
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.name = tracker.name
        trackerCoreData.schedule = tracker.schedule as NSObject
        trackerCoreData.daysString = tracker.schedule.map(\.rawValue).joined(separator: ",")
        
        return trackerCoreData
    }
}
