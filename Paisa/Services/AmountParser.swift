//
//  AmountParser.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 02/11/26.
//

import Foundation

// MARK: - AmountParser
// Converts between the amount text field and integer minor units (paise).
// Rejects anything that isn't a plain positive rupee amount instead of guessing.

enum AmountParser {

    /// Whole rupees (up to ₹999,999,999,999, far from Int overflow) with up to two paise digits:
    /// "125", "125.", "125.5", "125.50", ".5".
    private static let amountPattern = #"^([0-9]{1,12}(\.[0-9]{0,2})?|\.[0-9]{1,2})$"#

    /// Paise for the typed amount, or nil if it isn't a valid positive amount.
    /// Grouping commas, the ₹ sign and surrounding spaces are ignored: "₹1,25,000.50" → 12500050.
    static func minorUnits(from text: String) -> Int? {
        let cleaned = text
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "₹", with: "")
            .trimmingCharacters(in: .whitespaces)
        guard cleaned.range(of: amountPattern, options: .regularExpression) != nil,
              let amount = Decimal(string: cleaned)
        else { return nil }

        let units = NSDecimalNumber(decimal: amount * 100).intValue
        return units > 0 ? units : nil
    }

    /// Text for editing a stored amount, readable by `minorUnits(from:)` in any locale:
    /// 50000 → "500", 12550 → "125.50".
    static func editableText(minorUnits: Int) -> String {
        let rupees = minorUnits / 100
        let paise = minorUnits % 100
        return paise == 0 ? "\(rupees)" : String(format: "%ld.%02ld", rupees, paise)
    }
}
