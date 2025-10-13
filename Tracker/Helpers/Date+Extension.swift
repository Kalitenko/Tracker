import Foundation

extension Date {
    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    func dayName() -> String {
        Self.dayFormatter.string(from: self).capitalized
    }
    
    var dayEnum: Day? {
        let name = Self.dayFormatter.string(from: self).capitalized
        return Day(rawValue: name)
    }
}
