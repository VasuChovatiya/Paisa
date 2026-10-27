//
//  Int+Extensions.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import Foundation

// MARK: - Int + Minor Units Helpers

extension Int {
    /// Converts stored minor units (paise) to Decimal currency value.
    var asAmount: Decimal {
        Decimal(self) / 100
    }

    /// Formats stored minor units (paise) into an Indian localized currency string (e.g. ₹1,250.00).
    var asFormattedCurrency: String {
        PaisaFormatter.currency(minorUnits: self)
    }
}
