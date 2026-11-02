//
//  AddTransactionViewModelTests.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 02/11/26.
//

import XCTest
@testable import Paisa

// MARK: - AddTransactionViewModelTests

final class AddTransactionViewModelTests: XCTestCase {

    private func makeCategory() -> Paisa.Category {
        Paisa.Category(name: "Food & Dining", icon: "fork.knife", colorHex: "#FF6B6B")
    }

    // MARK: - Validation

    func testNewFormIsInvalid() {
        XCTAssertFalse(AddTransactionViewModel().isValid)
    }

    func testValidNeedsAmountAndCategory() {
        let viewModel = AddTransactionViewModel()
        viewModel.amountString = "250"
        XCTAssertFalse(viewModel.isValid)

        viewModel.selectedCategory = makeCategory()
        XCTAssertTrue(viewModel.isValid)

        viewModel.amountString = "12abc"
        XCTAssertFalse(viewModel.isValid)
    }

    func testAmountIsParsedToMinorUnits() {
        let viewModel = AddTransactionViewModel()
        viewModel.amountString = "₹1,250.75"
        XCTAssertEqual(viewModel.amountMinorUnits, 125075)
    }

    // MARK: - Edit mode

    func testEditingLoadsTheStoredAmountUnchanged() {
        for units in [7, 12550, 50000, 12500050] {
            let tx = Transaction(amountMinorUnits: units, type: .expense)
            XCTAssertEqual(AddTransactionViewModel(editing: tx).amountMinorUnits, units)
        }
    }

    func testEditingLoadsEveryField() {
        let category = makeCategory()
        let date = Date(timeIntervalSince1970: 1_790_000_000)
        let tx = Transaction(
            amountMinorUnits: 12550, type: .income, date: date,
            category: category, paymentMethod: .card, note: "Refund"
        )

        let viewModel = AddTransactionViewModel(editing: tx)

        XCTAssertEqual(viewModel.amountString, "125.50")
        XCTAssertEqual(viewModel.selectedType, .income)
        XCTAssertTrue(viewModel.selectedCategory === category)
        XCTAssertEqual(viewModel.selectedDate, date)
        XCTAssertEqual(viewModel.selectedPaymentMethod, .card)
        XCTAssertEqual(viewModel.note, "Refund")
    }

    // MARK: - Smart defaults

    func testNewTransactionCopiesTypeCategoryAndMethodButNotAmount() {
        let category = makeCategory()
        let last = Transaction(
            amountMinorUnits: 99900, type: .income, category: category,
            paymentMethod: .bank, note: "Salary"
        )

        let viewModel = AddTransactionViewModel(lastTransaction: last)

        XCTAssertEqual(viewModel.selectedType, .income)
        XCTAssertTrue(viewModel.selectedCategory === category)
        XCTAssertEqual(viewModel.selectedPaymentMethod, .bank)
        XCTAssertEqual(viewModel.amountString, "")
        XCTAssertEqual(viewModel.note, "")
    }
}
