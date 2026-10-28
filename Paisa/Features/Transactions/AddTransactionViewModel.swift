//
//  AddTransactionViewModel.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI
import SwiftData

// MARK: - AddTransactionViewModel

@Observable
final class AddTransactionViewModel {
    // MARK: - Input fields
    var amountString: String = ""
    var selectedType: TransactionType = .expense
    var selectedCategory: Category?
    var selectedDate: Date = Date()
    var selectedPaymentMethod: PaymentMethod = .upi
    var note: String = ""

    // MARK: - State
    var showCategoryPicker: Bool = false
    var showValidationError: Bool = false
    var validationMessage: String = ""

    // MARK: - Init for editing
    init(editing transaction: Transaction? = nil, lastTransaction: Transaction? = nil) {
        if let tx = transaction {
            // Edit mode
            amountString         = formatAmount(tx.amountMinorUnits)
            selectedType         = tx.type
            selectedCategory     = tx.category
            selectedDate         = tx.date
            selectedPaymentMethod = tx.paymentMethod
            note                 = tx.note
        } else if let last = lastTransaction {
            // Pre-fill from last transaction (smart defaults)
            selectedType         = last.type
            selectedCategory     = last.category
            selectedPaymentMethod = last.paymentMethod
        }
    }

    // MARK: - Computed

    var amountMinorUnits: Int? {
        let cleaned = amountString
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "₹", with: "")
            .trimmingCharacters(in: .whitespaces)
        guard let amount = Decimal(string: cleaned), amount > 0 else { return nil }
        let units = NSDecimalNumber(decimal: amount * 100).intValue
        return units > 0 ? units : nil
    }

    var isValid: Bool {
        amountMinorUnits != nil && selectedCategory != nil
    }

    // MARK: - Save

    func save(context: ModelContext, editing existingTx: Transaction?) {
        guard let units = amountMinorUnits, let cat = selectedCategory else {
            validationMessage = amountMinorUnits == nil ? "Please enter a valid amount." : "Please select a category."
            showValidationError = true
            return
        }

        if let tx = existingTx {
            tx.amountMinorUnits  = units
            tx.type              = selectedType
            tx.date              = selectedDate
            tx.category          = cat
            tx.paymentMethod     = selectedPaymentMethod
            tx.note              = note
            tx.updatedAt         = Date()
        } else {
            let tx = Transaction(
                amountMinorUnits: units,
                type: selectedType,
                date: selectedDate,
                category: cat,
                paymentMethod: selectedPaymentMethod,
                note: note
            )
            context.insert(tx)
        }
        try? context.save()
    }

    // MARK: - Private helpers

    private func formatAmount(_ minorUnits: Int) -> String {
        let amount = Decimal(minorUnits) / 100
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return (formatter.string(from: amount as NSDecimalNumber)) ?? "\(amount)"
    }
}
