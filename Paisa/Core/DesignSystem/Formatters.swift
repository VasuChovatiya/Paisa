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

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.groupingSize = 3
        formatter.groupingSeparator = ","
        formatter.locale = Locale(identifier: "en_IN")
        return formatter
    }()

    /// Formats a Decimal as "₹1,25,000" (Indian grouping notation)
    static func currency(_ decimal: Decimal) -> String {
        let formatted = currencyFormatter.string(from: decimal as NSDecimalNumber) ?? "\(decimal)"
        return "₹\(formatted)"
    }

    /// Formats an Int minor-unit value (paise) as "₹125.50"
    static func currency(minorUnits: Int) -> String {
        currency(Decimal(minorUnits) / 100)
    }
}
