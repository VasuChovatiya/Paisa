//
//  Color+Extensions.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI

// MARK: - Color + Hex Initializers

extension Color {
    /// Initialize a SwiftUI Color from a hexadecimal string (e.g. "#00C896" or "00C896").
    init(hex: String) {
        var hexDigits = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexDigits.hasPrefix("#") { hexDigits.removeFirst() }

        let rgb: UInt64
        var value: UInt64 = 0
        if Scanner(string: hexDigits).scanHexInt64(&value) {
            rgb = value
        } else {
            rgb = 0
        }

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >>  8) & 0xFF) / 255.0
        let b = Double( rgb        & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }

    /// Hex color string from Category colorHex
    static func fromCategoryHex(_ hex: String) -> Color {
        Color(hex: hex)
    }
}
