//
//  Category.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import Foundation
import SwiftData

// MARK: - Category Type

enum CategoryType: String, Codable, CaseIterable {
    case expense = "expense"
    case income  = "income"
    case both    = "both"

    func matches(_ transactionType: TransactionType) -> Bool {
        self == .both || self.rawValue == transactionType.rawValue
    }

    static func == (lhs: CategoryType, rhs: TransactionType) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    static func == (lhs: TransactionType, rhs: CategoryType) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

// MARK: - Category

@Model
final class Category {
    var id: UUID
    var name: String
    var icon: String        // SF Symbol name
    var colorHex: String    // hex string e.g. "#FF6B6B"
    var type: CategoryType
    var isDefault: Bool
    var isArchived: Bool
    var sortOrder: Int

    @Relationship(deleteRule: .nullify, inverse: \Transaction.category)
    var transactions: [Transaction]

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        colorHex: String,
        type: CategoryType = .expense,
        isDefault: Bool = false,
        isArchived: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id           = id
        self.name         = name
        self.icon         = icon
        self.colorHex     = colorHex
        self.type         = type
        self.isDefault    = isDefault
        self.isArchived   = isArchived
        self.sortOrder    = sortOrder
        self.transactions = []
    }
}

// MARK: - Default Categories

extension Category {
    static var defaultCategories: [Category] {
        let expenseCategories: [(name: String, icon: String, color: String, order: Int)] = [
            ("Food & Dining",   "fork.knife",          "#FF6B6B", 0),
            ("Transport",       "car.fill",             "#FF9F43", 1),
            ("Shopping",        "bag.fill",             "#A29BFE", 2),
            ("Bills & Utilities","bolt.fill",           "#6C5CE7", 3),
            ("Health",          "heart.fill",           "#FD79A8", 4),
            ("Entertainment",   "play.fill",            "#00CEC9", 5),
            ("Travel",          "airplane",             "#0984E3", 6),
            ("Education",       "book.fill",            "#00B894", 7),
            ("Personal Care",   "sparkles",             "#E17055", 8),
            ("Other Expense",   "ellipsis.circle.fill", "#636E72", 9),
        ]

        let incomeCategories: [(name: String, icon: String, color: String, order: Int)] = [
            ("Salary",          "indianrupeesign.circle.fill", "#00B894", 10),
            ("Freelance",       "laptopcomputer",              "#0984E3", 11),
            ("Business",        "briefcase.fill",              "#6C5CE7", 12),
            ("Investment",      "chart.line.uptrend.xyaxis",   "#00CEC9", 13),
            ("Gift",            "gift.fill",                   "#FD79A8", 14),
            ("Other Income",    "plus.circle.fill",            "#A29BFE", 15),
        ]

        var all: [Category] = []

        for item in expenseCategories {
            all.append(Category(
                name: item.name,
                icon: item.icon,
                colorHex: item.color,
                type: .expense,
                isDefault: true,
                sortOrder: item.order
            ))
        }

        for item in incomeCategories {
            all.append(Category(
                name: item.name,
                icon: item.icon,
                colorHex: item.color,
                type: .income,
                isDefault: true,
                sortOrder: item.order
            ))
        }

        return all
    }
}
