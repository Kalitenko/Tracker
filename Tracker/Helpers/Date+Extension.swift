import Foundation

extension Date {
    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    var dayName: String {
       Self.dayFormatter.string(from: self).capitalized
    }
    
    var dayEnum: WeekDay? {
        let name = Self.dayFormatter.string(from: self).capitalized
        return WeekDay(rawValue: name)
    }
}
