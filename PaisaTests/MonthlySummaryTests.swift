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

    func testMonthOverMonthDecrease() throws {
        let current = MonthlySummary(month: Date(), transactions: [makeTransaction(amountMinorUnits: 7500, type: .expense)])
        let previous = MonthlySummary(month: Date(), transactions: [makeTransaction(amountMinorUnits: 10000, type: .expense)])

        let change = try XCTUnwrap(MonthlySummaryService.monthOverMonthChange(current: current, previous: previous))
        XCTAssertEqual(change, -0.25, accuracy: 0.001)
    }

    func testMonthOverMonthNoSpendThisMonthIsFullDecrease() throws {
        let current = MonthlySummary(month: Date(), transactions: [])
        let previous = MonthlySummary(month: Date(), transactions: [makeTransaction(amountMinorUnits: 10000, type: .expense)])

        let change = try XCTUnwrap(MonthlySummaryService.monthOverMonthChange(current: current, previous: previous))
        XCTAssertEqual(change, -1, accuracy: 0.001)
    }

    func testMonthOverMonthIgnoresIncome() throws {
        let current = MonthlySummary(month: Date(), transactions: [
            makeTransaction(amountMinorUnits: 10000, type: .expense),
            makeTransaction(amountMinorUnits: 900000, type: .income),
        ])
        let previous = MonthlySummary(month: Date(), transactions: [makeTransaction(amountMinorUnits: 10000, type: .expense)])

        let change = try XCTUnwrap(MonthlySummaryService.monthOverMonthChange(current: current, previous: previous))
        XCTAssertEqual(change, 0, accuracy: 0.001)
    }

    func testMonthOverMonthOnlyIncomeLastMonthHasNoBaseline() {
        let current = MonthlySummary(month: Date(), transactions: [makeTransaction(amountMinorUnits: 10000, type: .expense)])
        let previous = MonthlySummary(month: Date(), transactions: [makeTransaction(amountMinorUnits: 10000, type: .income)])

        XCTAssertNil(MonthlySummaryService.monthOverMonthChange(current: current, previous: previous))
    }

    // MARK: - Totals

    func testSummaryTotalsInRupees() throws {
        let txs = [
            makeTransactionOnDate(amountMinorUnits: 12550, type: .expense, year: 2026, month: 10, day: 3),
            makeTransactionOnDate(amountMinorUnits: 4450, type: .expense, year: 2026, month: 10, day: 9),
            makeTransactionOnDate(amountMinorUnits: 100000, type: .income, year: 2026, month: 10, day: 1),
        ]
        let summary = MonthlySummaryService.summary(for: txs[0].date, from: txs, calendar: calendar)

        XCTAssertEqual(summary.totalExpense, Decimal(170))
        XCTAssertEqual(summary.totalIncome, Decimal(1000))
        XCTAssertEqual(summary.netBalance, Decimal(830))
    }

    func testSummaryIncludesFirstAndLastMomentOfMonth() throws {
        let first = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 10, day: 1)))
        let next = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 11, day: 1)))
        let txs = [
            Transaction(amountMinorUnits: 100, type: .expense, date: first),
            Transaction(amountMinorUnits: 200, type: .expense, date: next.addingTimeInterval(-1)),
            Transaction(amountMinorUnits: 400, type: .expense, date: next),
        ]

        let summary = MonthlySummaryService.summary(for: first, from: txs, calendar: calendar)
        XCTAssertEqual(summary.totalExpenseMinorUnits, 300)
    }

    func testSummaryDoesNotMixUpTheSameMonthInAnotherYear() throws {
        let txs = [
            makeTransactionOnDate(amountMinorUnits: 5000, type: .expense, year: 2026, month: 10, day: 15),
            makeTransactionOnDate(amountMinorUnits: 9000, type: .expense, year: 2025, month: 10, day: 15),
        ]
        let summary = MonthlySummaryService.summary(for: txs[0].date, from: txs, calendar: calendar)
        XCTAssertEqual(summary.totalExpenseMinorUnits, 5000)
    }

    // MARK: - All Months

    func testAllMonthlySummariesEmpty() {
        XCTAssertTrue(MonthlySummaryService.allMonthlySummaries(from: [], calendar: calendar).isEmpty)
    }

    func testAllMonthlySummariesOnePerMonthNewestFirst() throws {
        let txs = [
            makeTransactionOnDate(amountMinorUnits: 1000, type: .expense, year: 2026, month: 8, day: 3),
            makeTransactionOnDate(amountMinorUnits: 2000, type: .expense, year: 2026, month: 10, day: 3),
            makeTransactionOnDate(amountMinorUnits: 3000, type: .expense, year: 2026, month: 10, day: 20),
            makeTransactionOnDate(amountMinorUnits: 4000, type: .expense, year: 2025, month: 12, day: 31),
        ]
        let summaries = MonthlySummaryService.allMonthlySummaries(from: txs, calendar: calendar)

        let months = summaries.map { calendar.dateComponents([.year, .month], from: $0.month) }
        XCTAssertEqual(months.map(\.year), [2026, 2026, 2025])
        XCTAssertEqual(months.map(\.month), [10, 8, 12])
        XCTAssertEqual(summaries.map(\.totalExpenseMinorUnits), [5000, 1000, 4000])
    }

    func testAllMonthlySummariesUseTheGivenCalendarsTimeZone() throws {
        // 31 Oct 11:00 UTC is already 1 Nov in Kiritimati (UTC+14), but still October in most
        // device time zones. Grouping must follow the calendar passed in, not the device.
        var kiritimati = Calendar(identifier: .gregorian)
        kiritimati.timeZone = try XCTUnwrap(TimeZone(identifier: "Pacific/Kiritimati"))
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = try XCTUnwrap(TimeZone(identifier: "UTC"))

        let lateOctober = try XCTUnwrap(utc.date(from: DateComponents(year: 2026, month: 10, day: 31, hour: 11)))
        let midOctober = try XCTUnwrap(utc.date(from: DateComponents(year: 2026, month: 10, day: 20, hour: 11)))
        let txs = [
            Transaction(amountMinorUnits: 1000, type: .expense, date: lateOctober),
            Transaction(amountMinorUnits: 2000, type: .expense, date: midOctober),
        ]
        let summaries = MonthlySummaryService.allMonthlySummaries(from: txs, calendar: kiritimati)

        XCTAssertEqual(summaries.map { kiritimati.component(.month, from: $0.month) }, [11, 10])
        XCTAssertEqual(summaries.map(\.totalExpenseMinorUnits), [1000, 2000])
    }
}
