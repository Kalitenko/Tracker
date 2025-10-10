import UIKit

final class EntityMapper {
    
    static func convertToTrackerCategory(_ entity: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let title = entity.title else { return nil }
        
        let trackersSet = entity.trackers as? Set<TrackerCoreData> ?? []
        let trackers = trackersSet.compactMap { convertToTracker($0) }
        
        return TrackerCategory(title: title, trackers: trackers)
    }
    
    static func convertToTracker(_ entity: TrackerCoreData) -> Tracker? {
        guard let name = entity.name,
              let color = entity.color as? UIColor,
              let emoji = entity.emoji,
              let schedule = entity.schedule as? [Day] else {
            return nil
        }
        let id = entity.id
        
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
    
    static func convertToTrackerRecord(_ entity: TrackerRecordCoreData) -> TrackerRecord? {
        guard let date = entity.date else {
            return nil
        }
        let trackerId = entity.trackerID
        
        return TrackerRecord(trackerId: trackerId, date: date)
    }
    
    static func convertToTrackerCoreData(tracker: Tracker,
                                         trackerCoreData: TrackerCoreData) -> TrackerCoreData? {
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.name = tracker.name
        trackerCoreData.schedule = tracker.schedule as NSObject
        
        return trackerCoreData
    }
}
