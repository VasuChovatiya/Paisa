//
//  View+Extensions.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI

// MARK: - View + Paisa Styling Extensions

extension View {
    // MARK: Card style
    func paisaCard(padding: CGFloat = PaisaSpacing.md) -> some View {
        self
            .padding(padding)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: PaisaRadius.lg, style: .continuous))
    }

    // MARK: Glow effect
    func glowEffect(color: Color, radius: CGFloat = 12, opacity: Double = 0.35) -> some View {
        self.shadow(color: color.opacity(opacity), radius: radius, x: 0, y: 4)
    }

    // MARK: Shimmer / loading placeholder
    func shimmer(isLoading: Bool) -> some View {
        self.redacted(reason: isLoading ? .placeholder : [])
    }
}
