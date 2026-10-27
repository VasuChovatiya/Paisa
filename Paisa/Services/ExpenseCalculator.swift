//
//  ExpenseCalculator.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import Foundation

// MARK: - ExpenseCalculator
// All arithmetic is done in integer minor units to avoid floating-point drift.

enum ExpenseCalculator {

    // MARK: - Totals

    static func totalExpenses(from transactions: [Transaction]) -> Int {
        transactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amountMinorUnits }
    }

    static func totalIncome(from transactions: [Transaction]) -> Int {
        transactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amountMinorUnits }
    }

    /// Net balance = income − expenses (recorded transactions only, no opening balance)
    static func netBalance(from transactions: [Transaction]) -> Int {
        totalIncome(from: transactions) - totalExpenses(from: transactions)
    }

    // MARK: - Category Breakdown

    struct CategoryTotal: Identifiable {
        let id: UUID
        let category: Category
        let totalMinorUnits: Int
        var percentage: Double

        var amount: Decimal { Decimal(totalMinorUnits) / 100 }
    }

    static func categoryBreakdown(
        from transactions: [Transaction],
        type: TransactionType
    ) -> [CategoryTotal] {
        let filtered = transactions.filter { $0.type == type }
        let grandTotal = filtered.reduce(0) { $0 + $1.amountMinorUnits }

        // Group by category
        var map: [UUID: (Category, Int)] = [:]
        for tx in filtered {
            guard let cat = tx.category else { continue }
            let existing = map[cat.id]?.1 ?? 0
            map[cat.id] = (cat, existing + tx.amountMinorUnits)
        }

        return map.map { key, value in
            let pct = grandTotal > 0 ? Double(value.1) / Double(grandTotal) : 0
            return CategoryTotal(
                id: key,
                category: value.0,
                totalMinorUnits: value.1,
                percentage: pct
            )
        }
        .sorted { $0.totalMinorUnits > $1.totalMinorUnits }
    }

    // MARK: - Daily Breakdown

    struct DailyTotal: Identifiable {
        let id: Date
        let date: Date
        let expenseMinorUnits: Int
        let incomeMinorUnits: Int

        var expense: Decimal { Decimal(expenseMinorUnits) / 100 }
        var income: Decimal  { Decimal(incomeMinorUnits)  / 100 }
    }

    static func dailyBreakdown(
        from transactions: [Transaction],
        in month: Date,
        calendar: Calendar = .current
    ) -> [DailyTotal] {
        let days = daysInMonth(month, calendar: calendar)
        var result: [DailyTotal] = []

        for day in days {
            let dayTransactions = transactions.filter {
                calendar.isDate($0.date, inSameDayAs: day)
            }
            let exp = dayTransactions
                .filter { $0.type == .expense }
                .reduce(0) { $0 + $1.amountMinorUnits }
            let inc = dayTransactions
                .filter { $0.type == .income }
                .reduce(0) { $0 + $1.amountMinorUnits }
            result.append(DailyTotal(id: day, date: day, expenseMinorUnits: exp, incomeMinorUnits: inc))
        }
        return result
    }

    // MARK: - Helpers

    private static func daysInMonth(_ date: Date, calendar: Calendar) -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))
        else { return [] }

        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
}
