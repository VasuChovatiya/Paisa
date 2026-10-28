//
//  MonthlySummaryService.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import Foundation

// MARK: - MonthlySummary

struct MonthlySummary {
    let month: Date
    let transactions: [Transaction]

    var totalExpenseMinorUnits: Int { ExpenseCalculator.totalExpenses(from: transactions) }
    var totalIncomeMinorUnits: Int { ExpenseCalculator.totalIncome(from: transactions) }
    var netBalanceMinorUnits: Int { ExpenseCalculator.netBalance(from: transactions) }

    var totalExpense: Decimal { Decimal(totalExpenseMinorUnits) / 100 }
    var totalIncome: Decimal { Decimal(totalIncomeMinorUnits)  / 100 }
    var netBalance: Decimal { Decimal(netBalanceMinorUnits)   / 100 }

    var categoryBreakdown: [ExpenseCalculator.CategoryTotal] {
        ExpenseCalculator.categoryBreakdown(from: transactions, type: .expense)
    }

    var dailyBreakdown: [ExpenseCalculator.DailyTotal] {
        ExpenseCalculator.dailyBreakdown(from: transactions, in: month)
    }
}

// MARK: - MonthlySummaryService

enum MonthlySummaryService {

    /// Filter and group transactions that belong to the given calendar month.
    /// Month boundaries use the device's current calendar and timezone.
    static func summary(
        for month: Date,
        from allTransactions: [Transaction],
        calendar: Calendar = .current
    ) -> MonthlySummary {
        let components = calendar.dateComponents([.year, .month], from: month)

        let filtered = allTransactions.filter { tx in
            let txComponents = calendar.dateComponents([.year, .month], from: tx.date)
            return txComponents.year == components.year &&
                   txComponents.month == components.month
        }

        return MonthlySummary(month: month, transactions: filtered)
    }

    /// Returns one MonthlySummary per calendar month found in the transactions array,
    /// sorted most-recent first.
    static func allMonthlySummaries(
        from allTransactions: [Transaction],
        calendar: Calendar = .current
    ) -> [MonthlySummary] {
        var seen: Set<String> = []
        var months: [Date] = []

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"

        for tx in allTransactions {
            let key = formatter.string(from: tx.date)
            if seen.insert(key).inserted {
                let comps = calendar.dateComponents([.year, .month], from: tx.date)
                if let monthStart = calendar.date(from: comps) {
                    months.append(monthStart)
                }
            }
        }

        return months
            .sorted(by: >)
            .map { summary(for: $0, from: allTransactions, calendar: calendar) }
    }

    /// Month-over-month expense change as a percentage (-1.0 = 100% decrease, +0.5 = 50% increase)
    static func monthOverMonthChange(
        current: MonthlySummary,
        previous: MonthlySummary
    ) -> Double? {
        let prev = previous.totalExpenseMinorUnits
        guard prev > 0 else { return nil }
        let curr = current.totalExpenseMinorUnits
        return Double(curr - prev) / Double(prev)
    }
}
