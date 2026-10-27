//
//  Transaction.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import Foundation
import SwiftData

// MARK: - Transaction Type

enum TransactionType: String, Codable, CaseIterable {
    case expense = "expense"
    case income  = "income"
}

// MARK: - Payment Method

enum PaymentMethod: String, Codable, CaseIterable {
    case cash   = "Cash"
    case upi    = "UPI"
    case card   = "Card"
    case bank   = "Bank Transfer"
    case other  = "Other"

    var icon: String {
        switch self {
        case .cash:  return "banknote"
        case .upi:   return "qrcode"
        case .card:  return "creditcard"
        case .bank:  return "building.columns"
        case .other: return "ellipsis.circle"
        }
    }
}

// MARK: - Transaction

/// Stores amounts as integer minor units (paise for INR) to avoid floating-point errors.
/// ₹125.50 → amountMinorUnits = 12550
@Model
final class Transaction {
    var id: UUID
    var amountMinorUnits: Int          // always positive
    var type: TransactionType
    var date: Date
    var paymentMethod: PaymentMethod
    var note: String
    var createdAt: Date
    var updatedAt: Date

    // Relationship
    @Relationship(deleteRule: .nullify)
    var category: Category?

    init(
        id: UUID = UUID(),
        amountMinorUnits: Int,
        type: TransactionType,
        date: Date = Date(),
        category: Category? = nil,
        paymentMethod: PaymentMethod = .upi,
        note: String = ""
    ) {
        self.id               = id
        self.amountMinorUnits = amountMinorUnits
        self.type             = type
        self.date             = date
        self.category         = category
        self.paymentMethod    = paymentMethod
        self.note             = note
        self.createdAt        = Date()
        self.updatedAt        = Date()
    }

    // MARK: - Helpers

    /// Display amount as a Decimal (safe for presentation, not arithmetic)
    var amount: Decimal {
        Decimal(amountMinorUnits) / 100
    }

    /// Signed amount: negative for expenses, positive for income
    var signedAmount: Decimal {
        type == .expense ? -amount : amount
    }
}
