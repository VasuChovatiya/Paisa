//
//  PaisaTag.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI

// MARK: - PaisaTag
// Pill-shaped label used for transaction types, category types, and status badges.

struct PaisaTag: View {
    let text: String
    var color: Color = PaisaColors.primary
    var size: CGFloat = 11

    var body: some View {
        Text(text)
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}
