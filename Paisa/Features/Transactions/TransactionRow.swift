//
//  TransactionRow.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI

// MARK: - TransactionRow

struct TransactionRow: View {
    let transaction: Transaction
    var showDate: Bool = false

    var body: some View {
        HStack(spacing: PaisaSpacing.md) {
            // Category icon badge
            PaisaIconBadge(
                icon: transaction.category?.icon ?? "questionmark",
                color: Color(hex: transaction.category?.colorHex ?? "#636E72"),
                size: 44
            )

            // Title and subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category?.name ?? "Uncategorized")
                    .font(PaisaFont.callout())
                    .foregroundStyle(PaisaColors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: transaction.paymentMethod.icon)
                        .font(.system(size: 10))
                        .foregroundStyle(PaisaColors.textTertiary)
                    Text(transaction.paymentMethod.rawValue)
                        .font(PaisaFont.caption())
                        .foregroundStyle(PaisaColors.textTertiary)
                    if showDate {
                        Text("· \(transaction.date.transactionDisplayString)")
                            .font(PaisaFont.caption())
                            .foregroundStyle(PaisaColors.textTertiary)
                    }
                }

                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(PaisaFont.caption())
                        .foregroundStyle(PaisaColors.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Amount
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(transaction.type == .income ? "+" : "-")\(PaisaFormatter.currency(transaction.amount))")
                    .font(PaisaFont.mono(size: 15, weight: .semibold))
                    .foregroundStyle(
                        transaction.type == .income ? PaisaColors.income : PaisaColors.expense
                    )
                    .lineLimit(1)

                PaisaTag(
                    text: transaction.type == .income ? "Income" : "Expense",
                    color: transaction.type == .income ? PaisaColors.income : PaisaColors.expense,
                    size: 10
                )
            }
        }
        .padding(.vertical, 4)
    }
}
