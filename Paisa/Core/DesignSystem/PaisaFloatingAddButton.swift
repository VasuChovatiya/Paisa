//
//  PaisaFloatingAddButton.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI

// MARK: - PaisaFloatingAddButton
// Gradient capsule FAB with a glow effect. Sits pinned above the tab bar on Dashboard.

struct PaisaFloatingAddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.system(size: 17, weight: .bold))
                Text("Add")
                    .font(PaisaFont.headline())
            }
            .foregroundStyle(.black)
            .padding(.horizontal, PaisaSpacing.lg)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [PaisaColors.primary, Color(hex: "#00E5A5")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Capsule())
            .glowEffect(color: PaisaColors.primary, radius: 16, opacity: 0.5)
        }
        .buttonStyle(.plain)
    }
}
