import Foundation

final class Utils {
    
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
    static func localizedNumber(_ number: Double) -> String {
        guard let string = formatter.string(from: NSNumber(value: number)) else {
            Logger.warning("Не получилось преобразовать \(number)")
            return "0.00"
        }
        return string
    }
    
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
