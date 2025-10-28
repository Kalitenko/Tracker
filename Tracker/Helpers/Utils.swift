import Foundation

final class Utils {
    private enum DayForms {
        static let singular = "день"
        static let few = "дня"
        static let many = "дней"
    }
    
    static func dayCountString(for number: Int) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "Days count with plural"),
            number
        )
    }
}
