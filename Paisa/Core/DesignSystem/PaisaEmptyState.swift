//
//  PaisaEmptyState.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI

// MARK: - PaisaEmptyState
// Centred icon + title + subtitle placeholder for screens or sections with no data.

struct PaisaEmptyState: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: PaisaSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 52, weight: .light))
                .foregroundStyle(PaisaColors.textTertiary)
                .padding(.bottom, 4)

            Text(title)
                .font(PaisaFont.title3())
                .foregroundStyle(PaisaColors.textPrimary)

            Text(subtitle)
                .font(PaisaFont.body())
                .foregroundStyle(PaisaColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, PaisaSpacing.xl)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, PaisaSpacing.xxl)
    }
}
