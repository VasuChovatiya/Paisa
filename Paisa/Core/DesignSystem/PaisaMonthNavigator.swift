//
//  PaisaMonthNavigator.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI

// MARK: - PaisaMonthNavigator
// Left/right chevron controls for stepping through calendar months.
// Forward navigation is disabled when the next month would be in the future.

struct PaisaMonthNavigator: View {
    @Binding var selectedMonth: Date

    private var canGoForward: Bool {
        selectedMonth.addingMonths(1) <= Date()
    }

    var body: some View {
        HStack(spacing: PaisaSpacing.md) {
            // ← Previous month
            Button {
                withAnimation(.spring(duration: 0.3)) {
                    selectedMonth = selectedMonth.addingMonths(-1)
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(PaisaColors.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(PaisaColors.bgCard)
                    .clipShape(Circle())
            }

            Text(selectedMonth.monthYearString)
                .font(PaisaFont.headline())
                .foregroundStyle(PaisaColors.textPrimary)
                .frame(minWidth: 130)

            // → Next month (disabled if it would be a future month)
            Button {
                withAnimation(.spring(duration: 0.3)) {
                    selectedMonth = selectedMonth.addingMonths(1)
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(canGoForward ? PaisaColors.textSecondary : PaisaColors.textTertiary)
                    .frame(width: 32, height: 32)
                    .background(PaisaColors.bgCard)
                    .clipShape(Circle())
            }
            .disabled(!canGoForward)
        }
    }
}
