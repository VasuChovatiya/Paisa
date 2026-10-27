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
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        f.groupingSize = 3
        f.groupingSeparator = ","
        f.locale = Locale(identifier: "en_IN")
        return f
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
