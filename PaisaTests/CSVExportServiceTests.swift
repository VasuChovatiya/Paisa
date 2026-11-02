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

    func testFileNameUsesStartMonth() throws {
        var opts = CSVExportService.ExportOptions()
        opts.startDate = try date(2026, 3, 14)
        XCTAssertEqual(CSVExportService.fileName(for: opts), "Paisa_Export_2026-03.csv")
    }

    // MARK: - Rows

    // CSV dates are written in the device time zone, so build them with the device calendar.
    private let calendar = Calendar.current

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) throws -> Date {
        try XCTUnwrap(calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour)))
    }

    private func rows(_ csv: String) -> [String] {
        csv.components(separatedBy: "\r\n")
    }

    func testFullRow() throws {
        let category = Paisa.Category(name: "Food & Dining", icon: "fork.knife", colorHex: "#FF6B6B")
        let tx = Transaction(
            amountMinorUnits: 12550, type: .expense, date: try date(2026, 10, 15),
            category: category, paymentMethod: .upi, note: "Lunch"
        )
        let csv = CSVExportService.generateCSV(from: [tx])
        XCTAssertEqual(rows(csv), [
            "Date,Type,Category,Amount,Currency,Payment Method,Note",
            "2026-10-15,Expense,Food & Dining,125.50,INR,UPI,Lunch",
        ])
    }

    func testIncomeRow() throws {
        let tx = Transaction(amountMinorUnits: 4500000, type: .income, date: try date(2026, 10, 1), paymentMethod: .bank)
        var opts = CSVExportService.ExportOptions()
        opts.includeHeader = false
        XCTAssertEqual(
            CSVExportService.generateCSV(from: [tx], options: opts),
            "2026-10-01,Income,Uncategorized,45000.00,INR,Bank Transfer,"
        )
    }

    func testLargeAmountHasNoGroupingSeparator() {
        let tx = makeTransaction(amountMinorUnits: 1234567890, type: .expense)
        let csv = CSVExportService.generateCSV(from: [tx])
        XCTAssertTrue(csv.contains(",12345678.90,"))
    }

    func testSmallAmountKeepsLeadingZero() {
        let tx = makeTransaction(amountMinorUnits: 5, type: .expense)
        let csv = CSVExportService.generateCSV(from: [tx])
        XCTAssertTrue(csv.contains(",0.05,"))
    }

    func testMissingCategoryIsUncategorized() {
        let csv = CSVExportService.generateCSV(from: [makeTransaction(amountMinorUnits: 100, type: .expense)])
        XCTAssertTrue(csv.contains(",Uncategorized,"))
    }

    func testRowsAreSortedOldestFirstWithCRLF() throws {
        let txs = [
            Transaction(amountMinorUnits: 300, type: .expense, date: try date(2026, 10, 3)),
            Transaction(amountMinorUnits: 100, type: .expense, date: try date(2026, 10, 1)),
            Transaction(amountMinorUnits: 200, type: .expense, date: try date(2026, 10, 2)),
        ]
        let csv = CSVExportService.generateCSV(from: txs)
        let dates = rows(csv).dropFirst().map { $0.prefix(10) }

        XCTAssertEqual(dates, ["2026-10-01", "2026-10-02", "2026-10-03"])
        XCTAssertFalse(csv.replacingOccurrences(of: "\r\n", with: "").contains("\n"))
        XCTAssertFalse(csv.hasSuffix("\r\n"))
    }

    // MARK: - Date range

    private func exportDates(_ txs: [Transaction], from start: Date?, to end: Date?) -> [String] {
        var opts = CSVExportService.ExportOptions()
        opts.startDate = start
        opts.endDate = end
        opts.includeHeader = false
        return rows(CSVExportService.generateCSV(from: txs, options: opts, calendar: calendar))
            .filter { !$0.isEmpty }
            .map { String($0.prefix(10)) }
    }

    func testRangeIncludesStartAndTheWholeEndDay() throws {
        let txs = [
            Transaction(amountMinorUnits: 100, type: .expense, date: try date(2026, 9, 30, hour: 23)),
            Transaction(amountMinorUnits: 100, type: .expense, date: try date(2026, 10, 1, hour: 0)),
            Transaction(amountMinorUnits: 100, type: .expense, date: try date(2026, 10, 31, hour: 23)),
            Transaction(amountMinorUnits: 100, type: .expense, date: try date(2026, 11, 1, hour: 0)),
        ]
        // An end date at noon still includes the whole of 31 October.
        let exported = exportDates(txs, from: try date(2026, 10, 1, hour: 0), to: try date(2026, 10, 31))
        XCTAssertEqual(exported, ["2026-10-01", "2026-10-31"])
    }

    func testOpenEndedRanges() throws {
        let txs = [
            Transaction(amountMinorUnits: 100, type: .expense, date: try date(2026, 1, 1)),
            Transaction(amountMinorUnits: 100, type: .expense, date: try date(2026, 12, 31)),
        ]
        XCTAssertEqual(exportDates(txs, from: try date(2026, 6, 1), to: nil), ["2026-12-31"])
        XCTAssertEqual(exportDates(txs, from: nil, to: try date(2026, 6, 1)), ["2026-01-01"])
        XCTAssertEqual(exportDates(txs, from: nil, to: nil).count, 2)
    }

    // MARK: - More escaping

    func testNoteWithNewlineIsQuoted() {
        let tx = makeTransaction(amountMinorUnits: 1000, type: .expense, note: "line one\nline two")
        let csv = CSVExportService.generateCSV(from: [tx])
        XCTAssertTrue(csv.hasSuffix(",\"line one\nline two\""))
    }

    func testCarriageReturnInNoteDoesNotBreakTheRow() {
        let tx = makeTransaction(amountMinorUnits: 1000, type: .expense, note: "a\rb")
        var opts = CSVExportService.ExportOptions()
        opts.includeHeader = false
        let csv = CSVExportService.generateCSV(from: [tx], options: opts)
        XCTAssertFalse(csv.contains("\r"))
        XCTAssertTrue(csv.hasSuffix(",a b"))
    }

    func testPlainNoteIsNotQuoted() {
        let tx = makeTransaction(amountMinorUnits: 1000, type: .expense, note: "Chai")
        XCTAssertTrue(CSVExportService.generateCSV(from: [tx]).hasSuffix(",Chai"))
    }

    // MARK: - More formula injection

    func testEveryRiskyLeadingCharacterIsNeutralised() {
        // OWASP CSV injection: =, +, -, @, tab and carriage return can all start a formula.
        for prefix in ["=", "+", "-", "@", "\t", "\r"] {
            let tx = makeTransaction(amountMinorUnits: 1000, type: .expense, note: "\(prefix)cmd|' /C calc'!A0")
            let csv = CSVExportService.generateCSV(from: [tx])
            let note = csv.components(separatedBy: ",INR,UPI,").last ?? ""
            XCTAssertTrue(
                note.hasPrefix("'") || note.hasPrefix("\"'"),
                "note starting with \(prefix.debugDescription) was not neutralised: \(note.debugDescription)"
            )
        }
    }

    func testRiskyCharacterInsideNoteIsLeftAlone() {
        let tx = makeTransaction(amountMinorUnits: 1000, type: .expense, note: "2+2=4")
        XCTAssertTrue(CSVExportService.generateCSV(from: [tx]).hasSuffix(",2+2=4"))
    }

    func testCategoryNameIsSanitizedToo() {
        let category = Paisa.Category(name: "=HYPERLINK(\"x\")", icon: "tag", colorHex: "#000000")
        let tx = Transaction(amountMinorUnits: 1000, type: .expense, category: category)
        let csv = CSVExportService.generateCSV(from: [tx])
        XCTAssertTrue(csv.contains(",\"'=HYPERLINK(\"\"x\"\")\","))
    }

    // MARK: - File

    func testWriteToTemporaryFile() throws {
        let tx = makeTransaction(amountMinorUnits: 12550, type: .expense, note: "Lunch")
        let url = try CSVExportService.writeToTemporaryFile(from: [tx])
        defer { try? FileManager.default.removeItem(at: url) }

        XCTAssertEqual(url.pathExtension, "csv")
        XCTAssertEqual(url.deletingLastPathComponent().standardizedFileURL, FileManager.default.temporaryDirectory.standardizedFileURL)
        XCTAssertEqual(try String(contentsOf: url, encoding: .utf8), CSVExportService.generateCSV(from: [tx]))
    }
}
