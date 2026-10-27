//
//  CSVExportServiceTests.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import XCTest
@testable import Paisa

// MARK: - CSVExportServiceTests

final class CSVExportServiceTests: XCTestCase {

    private func makeTransaction(
        amountMinorUnits: Int,
        type: TransactionType,
        note: String = ""
    ) -> Transaction {
        Transaction(amountMinorUnits: amountMinorUnits, type: type, note: note)
    }

    // MARK: - Header

    func testHeaderIsPresent() {
        let csv = CSVExportService.generateCSV(from: [])
        XCTAssertTrue(csv.hasPrefix("Date,Type,Category,Amount,Currency,Payment Method,Note"))
    }

    func testHeaderCanBeOmitted() {
        var opts = CSVExportService.ExportOptions()
        opts.includeHeader = false
        let csv = CSVExportService.generateCSV(from: [], options: opts)
        XCTAssertFalse(csv.lowercased().contains("type"))
    }

    // MARK: - Empty export

    func testEmptyExportOnlyHeader() {
        let csv = CSVExportService.generateCSV(from: [])
        let lines = csv.components(separatedBy: "\r\n").filter { !$0.isEmpty }
        XCTAssertEqual(lines.count, 1) // header only
    }

    // MARK: - Amount formatting

    func testAmountFormattedWithTwoDecimals() {
        let tx = makeTransaction(amountMinorUnits: 12550, type: .expense)
        let csv = CSVExportService.generateCSV(from: [tx])
        XCTAssertTrue(csv.contains("125.50"))
    }

    func testWholeAmountFormattedWithTwoDecimals() {
        let tx = makeTransaction(amountMinorUnits: 50000, type: .income)
        let csv = CSVExportService.generateCSV(from: [tx])
        XCTAssertTrue(csv.contains("500.00"))
    }

    // MARK: - CSV escaping

    func testNoteWithCommaIsQuoted() {
        let tx = makeTransaction(amountMinorUnits: 1000, type: .expense, note: "Lunch, dinner")
        let csv = CSVExportService.generateCSV(from: [tx])
        XCTAssertTrue(csv.contains("\"Lunch, dinner\""))
    }

    func testNoteWithQuoteIsDoubleEscaped() {
        let tx = makeTransaction(amountMinorUnits: 1000, type: .expense, note: "He said \"hi\"")
        let csv = CSVExportService.generateCSV(from: [tx])
        XCTAssertTrue(csv.contains("\"He said \"\"hi\"\"\""))
    }

    // MARK: - Formula injection protection

    func testNoteStartingWithEqualSignIsSanitized() {
        let tx = makeTransaction(amountMinorUnits: 1000, type: .expense, note: "=SUM(A1:A10)")
        let csv = CSVExportService.generateCSV(from: [tx])
        XCTAssertFalse(csv.contains(",=SUM("))
        XCTAssertTrue(csv.contains("'=SUM("))
    }

    func testNoteStartingWithPlusIsSanitized() {
        let tx = makeTransaction(amountMinorUnits: 1000, type: .expense, note: "+HYPERLINK(\"bad.com\")")
        let csv = CSVExportService.generateCSV(from: [tx])
        XCTAssertFalse(csv.contains(",+HYPERLINK"))
    }

    // MARK: - Currency

    func testCurrencyIsINR() {
        let tx = makeTransaction(amountMinorUnits: 5000, type: .expense)
        let csv = CSVExportService.generateCSV(from: [tx])
        XCTAssertTrue(csv.contains("INR"))
    }

    // MARK: - File naming

    func testFileNameContainsPaisa() {
        let name = CSVExportService.fileName(for: CSVExportService.ExportOptions())
        XCTAssertTrue(name.hasPrefix("Paisa_Export_"))
        XCTAssertTrue(name.hasSuffix(".csv"))
    }
}
