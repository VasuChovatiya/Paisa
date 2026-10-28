//
//  MonthlySummaryTests.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import XCTest
@testable import Paisa

// MARK: - MonthlySummaryTests

final class MonthlySummaryTests: XCTestCase {

    private let calendar = Calendar.current

    private func makeTransaction(
        amountMinorUnits: Int,
        type: TransactionType,
        daysFromNow: Int = 0
    ) -> Transaction {
        let date = calendar.date(byAdding: .day, value: daysFromNow, to: Date()) ?? Date()
        return Transaction(amountMinorUnits: amountMinorUnits, type: type, date: date)
    }

    private func makeTransactionOnDate(
        amountMinorUnits: Int,
        type: TransactionType,
        year: Int,
        month: Int,
        day: Int
    ) -> Transaction {
        var comps = DateComponents()
        comps.year = year; comps.month = month; comps.day = day
        let date = calendar.date(from: comps) ?? Date()
        return Transaction(amountMinorUnits: amountMinorUnits, type: type, date: date)
    }

    // MARK: - Filtering

    func testSummaryFiltersCorrectMonth() throws {
        let thisMonth = makeTransactionOnDate(amountMinorUnits: 5000, type: .expense, year: 2026, month: 10, day: 15)
        let lastMonth = makeTransactionOnDate(amountMinorUnits: 3000, type: .expense, year: 2026, month: 9, day: 15)

        var target = DateComponents()
        target.year = 2026; target.month = 10
        let targetDate = try XCTUnwrap(calendar.date(from: target))

        let summary = MonthlySummaryService.summary(
            for: targetDate,
            from: [thisMonth, lastMonth],
            calendar: calendar
        )

        XCTAssertEqual(summary.transactions.count, 1)
        XCTAssertEqual(summary.totalExpenseMinorUnits, 5000)
    }

    func testSummaryEmpty() throws {
        var comps = DateComponents()
        comps.year = 2025; comps.month = 1
        let date = try XCTUnwrap(calendar.date(from: comps))

        let summary = MonthlySummaryService.summary(for: date, from: [], calendar: calendar)
        XCTAssertEqual(summary.totalExpenseMinorUnits, 0)
        XCTAssertEqual(summary.totalIncomeMinorUnits, 0)
        XCTAssertEqual(summary.netBalanceMinorUnits, 0)
    }

    // MARK: - Month-over-Month

    func testMonthOverMonthIncrease() throws {
        // Fixed dates: "31 days ago" lands two months back on the 1st after a 30-day month.
        let txCurrent  = makeTransactionOnDate(amountMinorUnits: 15000, type: .expense, year: 2026, month: 10, day: 1)
        let txPrevious = makeTransactionOnDate(amountMinorUnits: 10000, type: .expense, year: 2026, month: 9, day: 30)

        let current  = MonthlySummaryService.summary(for: txCurrent.date, from: [txCurrent], calendar: calendar)
        let previous = MonthlySummaryService.summary(for: txPrevious.date, from: [txPrevious], calendar: calendar)

        let change = try XCTUnwrap(MonthlySummaryService.monthOverMonthChange(current: current, previous: previous))
        XCTAssertEqual(change, 0.5, accuracy: 0.001) // 50% increase
    }

    func testMonthOverMonthNoPreviousData() throws {
        let txCurrent = makeTransaction(amountMinorUnits: 5000, type: .expense)
        let current   = MonthlySummaryService.summary(for: Date(), from: [txCurrent], calendar: calendar)

        var comps = DateComponents()
        comps.year = 2020; comps.month = 1
        let emptyDate = try XCTUnwrap(calendar.date(from: comps))
        let previous  = MonthlySummaryService.summary(for: emptyDate, from: [], calendar: calendar)

        let change = MonthlySummaryService.monthOverMonthChange(current: current, previous: previous)
        XCTAssertNil(change) // no previous data → nil
    }
}
