//
//  CSVExportService.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import Foundation

// MARK: - CSVExportService
// Generates RFC 4180-compliant CSV content from an array of Transactions.
// Protects against formula injection (fields starting with =, +, -, @, TAB, CR).

enum CSVExportService {

    // MARK: - Public API

    struct ExportOptions {
        var startDate: Date?
        var endDate: Date?
        var includeHeader: Bool = true
    }

    static func generateCSV(
        from transactions: [Transaction],
        options: ExportOptions = ExportOptions(),
        calendar: Calendar = .current
    ) -> String {
        let filtered = filter(transactions, options: options, calendar: calendar)

        var lines: [String] = []
        if options.includeHeader {
            lines.append(csvRow([
                "Date", "Type", "Category", "Amount", "Currency",
                "Payment Method", "Note"
            ]))
        }

        let dateFormatter = makeDateFormatter()
        let amountFormatter = makeAmountFormatter()

        for tx in filtered.sorted(by: { $0.date < $1.date }) {
            let row = csvRow([
                dateFormatter.string(from: tx.date),
                tx.type.rawValue.capitalized,
                tx.category?.name ?? "Uncategorized",
                amountFormatter.string(from: tx.amount as NSDecimalNumber) ?? "\(tx.amount)",
                "INR",
                tx.paymentMethod.rawValue,
                tx.note
            ])
            lines.append(row)
        }

        return lines.joined(separator: "\r\n")
    }

    static func fileName(for options: ExportOptions) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let suffix: String
        if let start = options.startDate {
            suffix = formatter.string(from: start)
        } else {
            suffix = formatter.string(from: Date())
        }
        return "Paisa_Export_\(suffix).csv"
    }

    static func writeToTemporaryFile(
        from transactions: [Transaction],
        options: ExportOptions = ExportOptions()
    ) throws -> URL {
        let csv = generateCSV(from: transactions, options: options)
        guard let data = csv.data(using: .utf8) else {
            throw CSVError.encodingFailed
        }

        let tmpDir = FileManager.default.temporaryDirectory
        let url = tmpDir.appendingPathComponent(fileName(for: options))
        try data.write(to: url, options: .atomic)
        return url
    }

    // MARK: - Errors

    enum CSVError: LocalizedError {
        case encodingFailed
        var errorDescription: String? { "Failed to encode CSV as UTF-8." }
    }

    // MARK: - Private Helpers

    private static func filter(
        _ transactions: [Transaction],
        options: ExportOptions,
        calendar: Calendar
    ) -> [Transaction] {
        transactions.filter { tx in
            if let start = options.startDate, tx.date < start { return false }
            if let end   = options.endDate {
                // Include the full end day
                guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: end)) else { return true }
                if tx.date >= endOfDay { return false }
            }
            return true
        }
    }

    private static func csvRow(_ fields: [String]) -> String {
        fields.map { escapeAndSanitize($0) }.joined(separator: ",")
    }

    /// RFC 4180 escaping + formula injection protection
    private static func escapeAndSanitize(_ field: String) -> String {
        var value = field

        // Formula injection protection: prefix with a single quote if starts with risky chars
        let injectionPrefixes: Set<Character> = ["=", "+", "-", "@"]
        if let first = value.first, injectionPrefixes.contains(first) {
            value = "'" + value
        }

        // Strip embedded carriage returns (replace with space)
        value = value.replacingOccurrences(of: "\r", with: " ")

        // If the field contains commas, double-quotes, or newlines, wrap in quotes
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            value = value.replacingOccurrences(of: "\"", with: "\"\"")
            value = "\"\(value)\""
        }

        return value
    }

    private static func makeDateFormatter() -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }

    private static func makeAmountFormatter() -> NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        f.locale = Locale(identifier: "en_US_POSIX")
        f.groupingSeparator = ""
        return f
    }
}
