//
//  PaisaIconBadge.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI

// MARK: - PaisaIconBadge
// Circular tinted icon badge used for category icons in lists and detail views.

struct PaisaIconBadge: View {
    let icon: String
    let color: Color
    var size: CGFloat = 40

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.18))
                .frame(width: size, height: size)
            Image(systemName: icon)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(color)
        }
    }
}
