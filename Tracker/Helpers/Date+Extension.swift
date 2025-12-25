import Foundation

extension Date {
    var weekDayEnum: WeekDay? {
        let weekdayIndex = Calendar.current.component(.weekday, from: self)
        return WeekDay.allCases.first(where: { $0.calendarWeekday == weekdayIndex })
    }
    
    var weekDayRawValue: String? {
        weekDayEnum?.rawValue
    }
}
