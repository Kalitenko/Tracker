import Foundation
import UIKit

struct Tracker {
    let id: UInt
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [Day]
}

enum Day: String, CaseIterable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
}
