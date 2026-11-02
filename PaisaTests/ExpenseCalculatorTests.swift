//
//  ExpenseCalculatorTests.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import XCTest
@testable import Paisa

// MARK: - ExpenseCalculatorTests

final class ExpenseCalculatorTests: XCTestCase {

    // MARK: - Helpers

    private func makeTransaction(
        amountMinorUnits: Int,
        type: TransactionType
    ) -> Transaction {
        Transaction(amountMinorUnits: amountMinorUnits, type: type)
    }

    // MARK: - Total Expenses

    func testTotalExpenses_empty() {
        XCTAssertEqual(ExpenseCalculator.totalExpenses(from: []), 0)
    }

    func testTotalExpenses_onlyIncome() {
        let txs = [makeTransaction(amountMinorUnits: 5000, type: .income)]
        XCTAssertEqual(ExpenseCalculator.totalExpenses(from: txs), 0)
    }

    func testTotalExpenses_mixed() {
        let txs = [
            makeTransaction(amountMinorUnits: 10000, type: .expense),
            makeTransaction(amountMinorUnits: 5000, type: .income),
            makeTransaction(amountMinorUnits: 3500, type: .expense),
        ]
        XCTAssertEqual(ExpenseCalculator.totalExpenses(from: txs), 13500)
    }

    // MARK: - Total Income

    func testTotalIncome_empty() {
        XCTAssertEqual(ExpenseCalculator.totalIncome(from: []), 0)
    }

    func testTotalIncome_onlyExpenses() {
        let txs = [makeTransaction(amountMinorUnits: 5000, type: .expense)]
        XCTAssertEqual(ExpenseCalculator.totalIncome(from: txs), 0)
    }

    func testTotalIncome_mixed() {
        let txs = [
            makeTransaction(amountMinorUnits: 50000, type: .income),
            makeTransaction(amountMinorUnits: 10000, type: .expense),
            makeTransaction(amountMinorUnits: 5000, type: .income),
        ]
        XCTAssertEqual(ExpenseCalculator.totalIncome(from: txs), 55000)
    }

    // MARK: - Net Balance

    func testNetBalance_zero() {
        XCTAssertEqual(ExpenseCalculator.netBalance(from: []), 0)
    }

    func testNetBalance_positive() {
        let txs = [
            makeTransaction(amountMinorUnits: 100000, type: .income),
            makeTransaction(amountMinorUnits: 30000, type: .expense),
        ]
        XCTAssertEqual(ExpenseCalculator.netBalance(from: txs), 70000)
    }

    func testNetBalance_negative() {
        let txs = [
            makeTransaction(amountMinorUnits: 10000, type: .income),
            makeTransaction(amountMinorUnits: 50000, type: .expense),
        ]
        XCTAssertEqual(ExpenseCalculator.netBalance(from: txs), -40000)
    }

    // MARK: - Amount Decimal

    func testAmountDecimalConversion() {
        let tx = makeTransaction(amountMinorUnits: 12550, type: .expense)
        XCTAssertEqual(tx.amount, Decimal(string: "125.50"))
    }

    func testSignedAmountExpense() {
        let tx = makeTransaction(amountMinorUnits: 5000, type: .expense)
        XCTAssertEqual(tx.signedAmount, Decimal(string: "-50.00"))
    }

    func testSignedAmountIncome() {
        let tx = makeTransaction(amountMinorUnits: 5000, type: .income)
        XCTAssertEqual(tx.signedAmount, Decimal(string: "50.00"))
    }

    func testPaiseSumWithoutFloatingPointDrift() {
        // 0.1 + 0.2 != 0.3 in Double; in paise it is exact.
        let txs = [
            makeTransaction(amountMinorUnits: 10, type: .expense),
            makeTransaction(amountMinorUnits: 20, type: .expense),
        ]
        let total = ExpenseCalculator.totalExpenses(from: txs)
        XCTAssertEqual(total, 30)
        XCTAssertEqual(total.asAmount, Decimal(string: "0.3"))
    }

    // MARK: - Category Breakdown

    private let food = Paisa.Category(name: "Food", icon: "fork.knife", colorHex: "#FF6B6B")
    private let travel = Paisa.Category(name: "Travel", icon: "airplane", colorHex: "#0984E3")
    private let salary = Paisa.Category(name: "Salary", icon: "indianrupeesign.circle.fill", colorHex: "#00B894", type: .income)

    private func makeTransaction(
        _ amountMinorUnits: Int,
        _ type: TransactionType,
        _ category: Paisa.Category?
    ) -> Transaction {
        Transaction(amountMinorUnits: amountMinorUnits, type: type, category: category)
    }

    func testCategoryBreakdown_empty() {
        XCTAssertTrue(ExpenseCalculator.categoryBreakdown(from: [], type: .expense).isEmpty)
    }

    func testCategoryBreakdown_groupsByCategory() {
        let txs = [
            makeTransaction(30000, .expense, food),
            makeTransaction(10000, .expense, travel),
            makeTransaction(20000, .expense, food),
        ]
        let breakdown = ExpenseCalculator.categoryBreakdown(from: txs, type: .expense)

        XCTAssertEqual(breakdown.count, 2)
        XCTAssertEqual(breakdown.first { $0.id == food.id }?.totalMinorUnits, 50000)
        XCTAssertEqual(breakdown.first { $0.id == travel.id }?.totalMinorUnits, 10000)
    }

    func testCategoryBreakdown_largestFirst() {
        let txs = [
            makeTransaction(10000, .expense, travel),
            makeTransaction(50000, .expense, food),
        ]
        let names = ExpenseCalculator.categoryBreakdown(from: txs, type: .expense).map(\.category.name)
        XCTAssertEqual(names, ["Food", "Travel"])
    }

    func testCategoryBreakdown_percentagesShareTheTotal() throws {
        let txs = [
            makeTransaction(75000, .expense, food),
            makeTransaction(25000, .expense, travel),
        ]
        let breakdown = ExpenseCalculator.categoryBreakdown(from: txs, type: .expense)

        XCTAssertEqual(try XCTUnwrap(breakdown.first { $0.id == food.id }).percentage, 0.75, accuracy: 1e-9)
        XCTAssertEqual(try XCTUnwrap(breakdown.first { $0.id == travel.id }).percentage, 0.25, accuracy: 1e-9)
        XCTAssertEqual(breakdown.map(\.percentage).reduce(0, +), 1, accuracy: 1e-9)
    }

    func testCategoryBreakdown_onlyCountsRequestedType() {
        let txs = [
            makeTransaction(10000, .expense, food),
            makeTransaction(500000, .income, salary),
        ]
        let expenses = ExpenseCalculator.categoryBreakdown(from: txs, type: .expense)
        let income = ExpenseCalculator.categoryBreakdown(from: txs, type: .income)

        XCTAssertEqual(expenses.map(\.category.name), ["Food"])
        XCTAssertEqual(expenses.first?.percentage, 1)
        XCTAssertEqual(income.map(\.category.name), ["Salary"])
    }

    func testCategoryBreakdown_uncategorisedSpendStillCountsTowardTheTotal() throws {
        let txs = [
            makeTransaction(50000, .expense, food),
            makeTransaction(50000, .expense, nil),
        ]
        let breakdown = ExpenseCalculator.categoryBreakdown(from: txs, type: .expense)

        XCTAssertEqual(breakdown.count, 1)
        XCTAssertEqual(try XCTUnwrap(breakdown.first).percentage, 0.5, accuracy: 1e-9)
    }

    func testCategoryTotalAmountIsInRupees() throws {
        let breakdown = ExpenseCalculator.categoryBreakdown(from: [makeTransaction(12550, .expense, food)], type: .expense)
        XCTAssertEqual(try XCTUnwrap(breakdown.first).amount, Decimal(string: "125.50"))
    }

    // MARK: - Daily Breakdown

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Kolkata") ?? .gmt
        return calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) throws -> Date {
        try XCTUnwrap(calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour)))
    }

    func testDailyBreakdown_oneEntryPerDayOfMonth() throws {
        XCTAssertEqual(ExpenseCalculator.dailyBreakdown(from: [], in: try date(2026, 10, 15), calendar: calendar).count, 31)
        XCTAssertEqual(ExpenseCalculator.dailyBreakdown(from: [], in: try date(2026, 11, 15), calendar: calendar).count, 30)
        XCTAssertEqual(ExpenseCalculator.dailyBreakdown(from: [], in: try date(2026, 2, 15), calendar: calendar).count, 28)
        XCTAssertEqual(ExpenseCalculator.dailyBreakdown(from: [], in: try date(2028, 2, 15), calendar: calendar).count, 29)
    }

    func testDailyBreakdown_startsOnTheFirst() throws {
        let days = ExpenseCalculator.dailyBreakdown(from: [], in: try date(2026, 10, 15), calendar: calendar)
        XCTAssertEqual(days.first?.date, try date(2026, 10, 1, hour: 0))
        XCTAssertEqual(days.last?.date, try date(2026, 10, 31, hour: 0))
    }

    func testDailyBreakdown_sumsEachDaySeparately() throws {
        let txs = [
            Transaction(amountMinorUnits: 10000, type: .expense, date: try date(2026, 10, 5, hour: 9)),
            Transaction(amountMinorUnits: 5000, type: .expense, date: try date(2026, 10, 5, hour: 21)),
            Transaction(amountMinorUnits: 200000, type: .income, date: try date(2026, 10, 5)),
            Transaction(amountMinorUnits: 7000, type: .expense, date: try date(2026, 10, 6)),
        ]
        let days = ExpenseCalculator.dailyBreakdown(from: txs, in: try date(2026, 10, 1), calendar: calendar)

        XCTAssertEqual(days[4].expenseMinorUnits, 15000)
        XCTAssertEqual(days[4].incomeMinorUnits, 200000)
        XCTAssertEqual(days[5].expenseMinorUnits, 7000)
        XCTAssertEqual(days.map(\.expenseMinorUnits).reduce(0, +), 22000)
    }

    func testDailyBreakdown_midnightBelongsToTheNewDay() throws {
        let txs = [
            Transaction(amountMinorUnits: 100, type: .expense, date: try date(2026, 10, 5, hour: 23).addingTimeInterval(3599)),
            Transaction(amountMinorUnits: 200, type: .expense, date: try date(2026, 10, 6, hour: 0)),
        ]
        let days = ExpenseCalculator.dailyBreakdown(from: txs, in: try date(2026, 10, 1), calendar: calendar)

        XCTAssertEqual(days[4].expenseMinorUnits, 100)
        XCTAssertEqual(days[5].expenseMinorUnits, 200)
    }

    func testDailyBreakdown_ignoresOtherMonths() throws {
        let txs = [
            Transaction(amountMinorUnits: 9900, type: .expense, date: try date(2026, 9, 30)),
            Transaction(amountMinorUnits: 9900, type: .expense, date: try date(2026, 11, 1)),
        ]
        let days = ExpenseCalculator.dailyBreakdown(from: txs, in: try date(2026, 10, 1), calendar: calendar)

        XCTAssertEqual(days.map(\.expenseMinorUnits).reduce(0, +), 0)
    }
}
