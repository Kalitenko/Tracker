import UIKit

struct Tracker {
    let id: Int32
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
    let isHabit: Bool
    let isPinned: Bool
    
    init(id: Int32, name: String, color: UIColor, emoji: String, schedule: [WeekDay], isHabit: Bool, isPinned: Bool = false) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.isHabit = isHabit
        self.isPinned = isPinned
    }
    
    init(name: String, color: UIColor, emoji: String, schedule: [WeekDay], isHabit: Bool, isPinned: Bool = false) {
        self.init(id: Int32.random(in: 1...Int32.max), name: name, color: color, emoji: emoji, schedule: schedule, isHabit: isHabit, isPinned: isPinned)
    }
    
    init(tracker: Tracker, isPinned: Bool) {
        let id = tracker.id
        let name = tracker.name
        let color = tracker.color
        let emoji = tracker.emoji
        let schedule = tracker.schedule
        let isHabit = tracker.isHabit
        self.init(id: id, name: name, color: color, emoji: emoji, schedule: schedule, isHabit: isHabit, isPinned: isPinned)
    }
}
