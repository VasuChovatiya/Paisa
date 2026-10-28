//
//  Spacing.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import CoreFoundation

// MARK: - Paisa Spacing Tokens

enum PaisaSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48

    /// Clearance height to keep scrollable content resting cleanly above the floating tab bar
    static let tabBarClearance: CGFloat = 100
}

// MARK: - Paisa Corner Radius Tokens

enum PaisaRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 14
    static let lg: CGFloat = 20
    static let xl: CGFloat = 28
    static let full: CGFloat = 999
}
