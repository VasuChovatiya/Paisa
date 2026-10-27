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
            makeTransaction(amountMinorUnits: 5000,  type: .income),
            makeTransaction(amountMinorUnits: 3500,  type: .expense),
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
            makeTransaction(amountMinorUnits: 5000,  type: .income),
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
            makeTransaction(amountMinorUnits: 30000,  type: .expense),
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
}
