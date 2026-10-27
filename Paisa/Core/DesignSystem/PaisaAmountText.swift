//
//  PaisaAmountText.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI

// MARK: - PaisaAmountText
// Large, styled monetary amount with optional income/expense colour coding and sign prefix.

struct PaisaAmountText: View {
    let amount: Decimal
    var type: TransactionType? = nil
    var size: CGFloat = 34
    var showSign: Bool = false

    private var color: Color {
        switch type {
        case .income:  return PaisaColors.income
        case .expense: return PaisaColors.expense
        case nil:      return PaisaColors.textPrimary
        }
    }

    private var prefix: String {
        guard showSign else { return "" }
        return type == .income ? "+" : "-"
    }

    var body: some View {
        Text("\(prefix)\(PaisaFormatter.currency(amount))")
            .font(PaisaFont.mono(size: size, weight: .bold))
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
    }
}
