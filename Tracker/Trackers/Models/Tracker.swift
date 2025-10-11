import UIKit

struct Tracker {
    let id: Int32
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [Day]
    
    init(id: Int32, name: String, color: UIColor, emoji: String, schedule: [Day]) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
    
    init(name: String, color: UIColor, emoji: String, schedule: [Day]) {
        self.init(id: Int32.random(in: 1...Int32.max), name: name, color: color, emoji: emoji, schedule: schedule)
    }
}
