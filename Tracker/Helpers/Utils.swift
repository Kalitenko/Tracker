final class Utils {
    private enum DayForms {
        static let singular = "день"
        static let few = "дня"
        static let many = "дней"
    }
    
    static func dayWord(for number: Int) -> String {
        let lastTwoDigits = number % 100
        let lastDigit = number % 10
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            return DayForms.many
        }
        
        switch lastDigit {
        case 1:
            return DayForms.singular
        case 2, 3, 4:
            return DayForms.few
        default:
            return DayForms.many
        }
    }
    
    static func dayCountString(for number: Int) -> String {
        "\(number) \(dayWord(for: number))"
    }
}
