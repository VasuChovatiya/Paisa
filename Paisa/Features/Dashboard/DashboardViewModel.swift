//
//  DashboardViewModel.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI
import SwiftData

// MARK: - DashboardViewModel

@Observable
final class DashboardViewModel {
    var selectedMonth: Date = Date()
    var showAddTransaction: Bool = false
    var transactionToEdit: Transaction? = nil

    private(set) var summary: MonthlySummary?

    func refresh(transactions: [Transaction]) {
        summary = MonthlySummaryService.summary(
            for: selectedMonth,
            from: transactions
        )
    }

    var recentTransactions: [Transaction] {
        (summary?.transactions ?? [])
            .sorted { $0.date > $1.date }
            .prefix(5)
            .map { $0 }
    }

    var isCurrentMonth: Bool {
        Calendar.current.isDate(selectedMonth, equalTo: Date(), toGranularity: .month)
    }
}
