//
//  Formatters.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import Foundation

// MARK: - PaisaFormatter
// Formats monetary amounts using Indian number notation (en_IN locale).
// All internal arithmetic uses integer minor units; this is display-only.

enum PaisaFormatter {

    /// Whole rupees drop the decimals; anything with paise shows both digits.
    private static let wholeFormatter = makeFormatter(fractionDigits: 0)
    private static let paiseFormatter = makeFormatter(fractionDigits: 2)

    /// Formats a Decimal as "₹1,25,000" or "₹125.50" (Indian grouping notation)
    static func currency(_ decimal: Decimal) -> String {
        let formatter = isWhole(decimal) ? wholeFormatter : paiseFormatter
        let formatted = formatter.string(from: decimal as NSDecimalNumber) ?? "\(decimal)"
        return "₹\(formatted)"
    }

    /// Formats an Int minor-unit value (paise) as "₹125.50"
    static func currency(minorUnits: Int) -> String {
        currency(Decimal(minorUnits) / 100)
    }

    private static func makeFormatter(fractionDigits: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        formatter.groupingSize = 3
        formatter.groupingSeparator = ","
        formatter.locale = Locale(identifier: "en_IN")
        return formatter
    }

    private static func isWhole(_ decimal: Decimal) -> Bool {
        var value = decimal
        var rounded = Decimal()
        NSDecimalRound(&rounded, &value, 0, .plain)
        return rounded == decimal
    }
}
