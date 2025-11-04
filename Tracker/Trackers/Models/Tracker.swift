import UIKit

struct Tracker {
    let id: Int32
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
    let isHabit: Bool
    
    init(id: Int32, name: String, color: UIColor, emoji: String, schedule: [WeekDay], isHabit: Bool) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.isHabit = isHabit
    }
    
    init(name: String, color: UIColor, emoji: String, schedule: [WeekDay], isHabit: Bool) {
        self.init(id: Int32.random(in: 1...Int32.max), name: name, color: color, emoji: emoji, schedule: schedule, isHabit: isHabit)
    }
}
