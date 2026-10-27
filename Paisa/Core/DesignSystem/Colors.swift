//
//  Colors.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI

// MARK: - Color + Paisa Design Tokens

extension Color {

    // MARK: - Brand
    static let paisaPrimary     = Color(hex: "#00C896")  // teal-green
    static let paisaPrimaryDark = Color(hex: "#009E78")
    static let paisaAccent      = Color(hex: "#FFB347")  // amber

    // MARK: - Semantic
    static let income           = Color(hex: "#00C896")
    static let expense          = Color(hex: "#FF6B6B")
    static let neutral          = Color(hex: "#A0AEC0")

    // MARK: - Backgrounds (dark-first)
    static let bgBase           = Color(hex: "#0D1117")
    static let bgSurface        = Color(hex: "#161B22")
    static let bgCard           = Color(hex: "#21262D")

    // MARK: - Text
    static let textPrimary      = Color(hex: "#F0F6FC")
    static let textSecondary    = Color(hex: "#8B949E")
    static let textTertiary     = Color(hex: "#484F58")
}

// MARK: - PaisaColors Namespace
// Provides access via `PaisaColors.primary` alongside `Color.paisaPrimary`.

enum PaisaColors {
    static let primary       = Color.paisaPrimary
    static let primaryDark   = Color.paisaPrimaryDark
    static let accent        = Color.paisaAccent

    static let income        = Color.income
    static let expense       = Color.expense
    static let neutral       = Color.neutral

    static let bgBase        = Color.bgBase
    static let bgSurface     = Color.bgSurface
    static let bgCard        = Color.bgCard

    static let textPrimary   = Color.textPrimary
    static let textSecondary = Color.textSecondary
    static let textTertiary  = Color.textTertiary
}
