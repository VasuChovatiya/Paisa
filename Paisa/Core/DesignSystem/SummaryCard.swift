//
//  SummaryCard.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI

// MARK: - SummaryCard
// Small card showing an icon, label, and a monetary total. Used in pairs on Dashboard.

struct SummaryCard: View {
    let title: String
    let amount: Decimal
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: PaisaSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(color)
                Text(title)
                    .font(PaisaFont.caption())
                    .foregroundStyle(PaisaColors.textSecondary)
            }

            Text(PaisaFormatter.currency(amount))
                .font(PaisaFont.mono(size: 18, weight: .bold))
                .foregroundStyle(PaisaColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .paisaCard()
    }
}
