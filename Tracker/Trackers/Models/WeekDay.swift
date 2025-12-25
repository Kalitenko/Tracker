enum WeekDay: String, CaseIterable, Codable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var localized: String {
        switch self {
        case .monday: L10n.monday
        case .tuesday: L10n.tuesday
        case .wednesday: L10n.wednesday
        case .thursday: L10n.thursday
        case .friday: L10n.friday
        case .saturday: L10n.saturday
        case .sunday: L10n.sunday
        }
    }
    var calendarWeekday: Int {
        switch self {
        case .sunday: 1
        case .monday: 2
        case .tuesday: 3
        case .wednesday: 4
        case .thursday: 5
        case .friday: 6
        case .saturday: 7
        }
    }
    var shortName: String {
        switch self {
        case .monday: L10n.monShort
        case .tuesday: L10n.tueShort
        case .wednesday: L10n.wedShort
        case .thursday: L10n.thuShort
        case .friday: L10n.friShort
        case .saturday: L10n.satShort
        case .sunday: L10n.sunShort
        }
    }
}

extension Array where Element == WeekDay {
    var displayText: String {
        count == WeekDay.allCases.count ? L10n.everyDay :
        sorted { $0.calendarWeekday < $1.calendarWeekday }.map { $0.shortName }.joined(separator: ", ")
    }
}
