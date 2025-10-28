import Foundation

final class Utils {
    static func dayCountString(for number: Int) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "Days count with plural"),
            number
        )
    }
    static func symbolCountString(for number: Int) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("numberOfSymbols", comment: "Symbols count with plural"),
            number
        )
    }
}
