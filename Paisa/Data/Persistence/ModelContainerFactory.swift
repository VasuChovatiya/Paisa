//
//  ModelContainerFactory.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftData
import Foundation

// MARK: - ModelContainerFactory

enum ModelContainerFactory {

    static func makeContainer() -> ModelContainer {
        let schema = Schema([Transaction.self, Category.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            seedDefaultCategoriesIfNeeded(in: container)
            seedSampleTransactionsIfNeeded(in: container)
            return container
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    static func makePreviewContainer() -> ModelContainer {
        let schema = Schema([Transaction.self, Category.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            seedDefaultCategoriesIfNeeded(in: container)
            seedSampleTransactions(in: container)
            return container
        } catch {
            fatalError("Failed to create preview ModelContainer: \(error)")
        }
    }

    // MARK: - Seeding Helpers

    static func seedDefaultCategoriesIfNeeded(in container: ModelContainer) {
        let context = ModelContext(container)
        seedDefaultCategoriesIfNeeded(in: context)
    }

    static func seedDefaultCategoriesIfNeeded(in context: ModelContext) {
        let descriptor = FetchDescriptor<Category>()
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }

        for category in Category.defaultCategories {
            context.insert(category)
        }
        try? context.save()
    }

    static func seedSampleTransactionsIfNeeded(in container: ModelContainer) {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Transaction>()
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }
        seedSampleTransactions(in: context)
    }

    static func seedSampleTransactions(in container: ModelContainer) {
        let context = ModelContext(container)
        seedSampleTransactions(in: context)
    }

    // Sample data reads best as one transaction per line.
    // swiftlint:disable:next function_body_length
    static func seedSampleTransactions(in context: ModelContext, clearExisting: Bool = false) {
        if clearExisting {
            let allTx = (try? context.fetch(FetchDescriptor<Transaction>())) ?? []
            for tx in allTx {
                context.delete(tx)
            }
            try? context.save()
        }

        seedDefaultCategoriesIfNeeded(in: context)

        let categories = (try? context.fetch(FetchDescriptor<Category>())) ?? []
        var categoryMap: [String: Category] = [:]
        for cat in categories {
            categoryMap[cat.name] = cat
        }

        let calendar = Calendar.current
        let now = Date()

        struct SampleItem {
            let minorUnits: Int
            let type: TransactionType
            let categoryName: String
            let method: PaymentMethod
            let note: String
            let daysAgo: Int
            let hour: Int
            let minute: Int
        }

        // swiftlint:disable line_length
        let samples: [SampleItem] = [
            // Today
            SampleItem(minorUnits: 38000, type: .expense, categoryName: "Food & Dining", method: .upi, note: "Blue Tokai Coffee & Croissant", daysAgo: 0, hour: 9, minute: 15),
            SampleItem(minorUnits: 49500, type: .expense, categoryName: "Food & Dining", method: .upi, note: "Blinkit - Daily Groceries & Milk", daysAgo: 0, hour: 13, minute: 20),
            SampleItem(minorUnits: 28000, type: .expense, categoryName: "Transport", method: .upi, note: "Uber to Coworking Space", daysAgo: 0, hour: 10, minute: 45),

            // Yesterday
            SampleItem(minorUnits: 84000, type: .expense, categoryName: "Food & Dining", method: .card, note: "Dinner at Social with Friends", daysAgo: 1, hour: 20, minute: 30),
            SampleItem(minorUnits: 32000, type: .expense, categoryName: "Transport", method: .upi, note: "Auto / Rapido commute", daysAgo: 1, hour: 18, minute: 10),
            SampleItem(minorUnits: 85000, type: .expense, categoryName: "Health", method: .card, note: "Apollo Pharmacy - Multivitamins", daysAgo: 1, hour: 15, minute: 40),

            // 2 days ago
            SampleItem(minorUnits: 62000, type: .expense, categoryName: "Food & Dining", method: .upi, note: "Swiggy - Gourmet Italian Dinner", daysAgo: 2, hour: 21, minute: 15),
            SampleItem(minorUnits: 189900, type: .expense, categoryName: "Health", method: .card, note: "Cult.fit Gym Monthly Membership", daysAgo: 2, hour: 7, minute: 30),

            // 3 days ago
            SampleItem(minorUnits: 349000, type: .expense, categoryName: "Shopping", method: .card, note: "Zara - Autumn Linen Shirt", daysAgo: 3, hour: 17, minute: 45),
            SampleItem(minorUnits: 220000, type: .expense, categoryName: "Transport", method: .card, note: "Shell Petrol Pump - Fuel Fill", daysAgo: 3, hour: 11, minute: 20),

            // 4 days ago
            SampleItem(minorUnits: 4500000, type: .income, categoryName: "Freelance", method: .bank, note: "Freelance Client Payout - Mobile UI", daysAgo: 4, hour: 14, minute: 0),
            SampleItem(minorUnits: 95000, type: .expense, categoryName: "Entertainment", method: .upi, note: "BookMyShow - IMAX Movie Tickets", daysAgo: 4, hour: 19, minute: 30),

            // 5 days ago
            SampleItem(minorUnits: 31000, type: .expense, categoryName: "Food & Dining", method: .upi, note: "Zepto - Midnight Snacks & Drinks", daysAgo: 5, hour: 23, minute: 10),
            SampleItem(minorUnits: 75000, type: .expense, categoryName: "Personal Care", method: .upi, note: "Truefitt & Hill - Haircut & Grooming", daysAgo: 5, hour: 16, minute: 0),

            // 7 days ago
            SampleItem(minorUnits: 117900, type: .expense, categoryName: "Bills & Utilities", method: .upi, note: "JioFiber Broadband Gigabit Plan", daysAgo: 7, hour: 10, minute: 15),
            SampleItem(minorUnits: 185000, type: .expense, categoryName: "Food & Dining", method: .card, note: "Nature's Basket - Organic Pantry", daysAgo: 7, hour: 12, minute: 45),

            // 9 days ago
            SampleItem(minorUnits: 799900, type: .expense, categoryName: "Shopping", method: .card, note: "Amazon India - Mechanical Keyboard & Mouse", daysAgo: 9, hour: 15, minute: 20),
            SampleItem(minorUnits: 14500, type: .expense, categoryName: "Transport", method: .upi, note: "Namma Metro Card Recharge", daysAgo: 9, hour: 9, minute: 10),

            // 11 days ago
            SampleItem(minorUnits: 245000, type: .expense, categoryName: "Bills & Utilities", method: .upi, note: "Electricity Bill - BESCOM", daysAgo: 11, hour: 11, minute: 30),
            SampleItem(minorUnits: 195000, type: .expense, categoryName: "Food & Dining", method: .card, note: "Dinner at Toit Brewery", daysAgo: 11, hour: 21, minute: 0),

            // 13 days ago
            SampleItem(minorUnits: 64900, type: .expense, categoryName: "Entertainment", method: .card, note: "Netflix 4K UHD Subscription", daysAgo: 13, hour: 8, minute: 30),
            SampleItem(minorUnits: 118900, type: .expense, categoryName: "Entertainment", method: .upi, note: "Spotify Premium Annual Family", daysAgo: 13, hour: 12, minute: 0),

            // 15 days ago
            SampleItem(minorUnits: 149900, type: .expense, categoryName: "Bills & Utilities", method: .upi, note: "Urban Company - Home Deep Cleaning", daysAgo: 15, hour: 14, minute: 15),
            SampleItem(minorUnits: 100000, type: .expense, categoryName: "Transport", method: .upi, note: "FASTag Wallet Auto-Topup", daysAgo: 15, hour: 10, minute: 0),

            // 17 days ago
            SampleItem(minorUnits: 289900, type: .expense, categoryName: "Shopping", method: .card, note: "Myntra - Nike Pegasus Running Shoes", daysAgo: 17, hour: 16, minute: 30),
            SampleItem(minorUnits: 18000, type: .expense, categoryName: "Food & Dining", method: .cash, note: "Chaayos - Adrak Chai & Bun Maska", daysAgo: 17, hour: 17, minute: 45),

            // 19 days ago
            SampleItem(minorUnits: 385000, type: .income, categoryName: "Investment", method: .bank, note: "Zerodha Mutual Fund Dividend Credited", daysAgo: 19, hour: 11, minute: 0),
            SampleItem(minorUnits: 90000, type: .expense, categoryName: "Health", method: .upi, note: "Practo - Dermatologist Consultation", daysAgo: 19, hour: 18, minute: 30),

            // 22 days ago
            SampleItem(minorUnits: 249000, type: .expense, categoryName: "Shopping", method: .card, note: "Uniqlo - Supima Cotton Tees", daysAgo: 22, hour: 15, minute: 0),
            SampleItem(minorUnits: 115000, type: .expense, categoryName: "Transport", method: .upi, note: "Uber Premier to Terminal 2", daysAgo: 22, hour: 6, minute: 30),

            // Earlier this month
            SampleItem(minorUnits: 16500000, type: .income, categoryName: "Salary", method: .bank, note: "Monthly Salary Credited - Tech Corp", daysAgo: 25, hour: 9, minute: 0),
            SampleItem(minorUnits: 2800000, type: .expense, categoryName: "Bills & Utilities", method: .bank, note: "Apartment Rent & Society Maintenance", daysAgo: 25, hour: 10, minute: 0),
            SampleItem(minorUnits: 450000, type: .expense, categoryName: "Education", method: .card, note: "Coursera Plus Annual Subscription", daysAgo: 26, hour: 14, minute: 0),
            SampleItem(minorUnits: 150000, type: .income, categoryName: "Gift", method: .upi, note: "Festival Shagun from Family", daysAgo: 26, hour: 18, minute: 30),

            // Previous Month (for Month-over-Month comparison & chart trends)
            SampleItem(minorUnits: 16500000, type: .income, categoryName: "Salary", method: .bank, note: "Monthly Salary Credited - Tech Corp", daysAgo: 55, hour: 9, minute: 0),
            SampleItem(minorUnits: 2800000, type: .expense, categoryName: "Bills & Utilities", method: .bank, note: "Apartment Rent & Society Maintenance", daysAgo: 54, hour: 10, minute: 0),
            SampleItem(minorUnits: 3500000, type: .income, categoryName: "Freelance", method: .bank, note: "Design System Consulting Payout", daysAgo: 48, hour: 15, minute: 0),
            SampleItem(minorUnits: 840000, type: .expense, categoryName: "Travel", method: .card, note: "MakeMyTrip - Flight Tickets", daysAgo: 45, hour: 12, minute: 0),
            SampleItem(minorUnits: 1250000, type: .expense, categoryName: "Travel", method: .card, note: "Taj Exotica Resort Booking", daysAgo: 43, hour: 14, minute: 0),
            SampleItem(minorUnits: 450000, type: .expense, categoryName: "Shopping", method: .card, note: "Apple Store - MagSafe & Accessories", daysAgo: 40, hour: 16, minute: 30),
            SampleItem(minorUnits: 220000, type: .expense, categoryName: "Bills & Utilities", method: .upi, note: "Electricity Bill - BESCOM", daysAgo: 38, hour: 11, minute: 0),
            SampleItem(minorUnits: 117900, type: .expense, categoryName: "Bills & Utilities", method: .upi, note: "JioFiber Broadband Gigabit Plan", daysAgo: 37, hour: 10, minute: 0),
            SampleItem(minorUnits: 189900, type: .expense, categoryName: "Health", method: .card, note: "Cult.fit Monthly Membership", daysAgo: 35, hour: 7, minute: 30),
            SampleItem(minorUnits: 345000, type: .expense, categoryName: "Food & Dining", method: .card, note: "Team Dinner at Smoke House Deli", daysAgo: 33, hour: 20, minute: 0),
            SampleItem(minorUnits: 125000, type: .expense, categoryName: "Shopping", method: .card, note: "Amazon - Books & Desk Organizer", daysAgo: 31, hour: 14, minute: 0),

            // Two Months Ago (history anchor)
            SampleItem(minorUnits: 16500000, type: .income, categoryName: "Salary", method: .bank, note: "Monthly Salary Credited - Tech Corp", daysAgo: 85, hour: 9, minute: 0),
            SampleItem(minorUnits: 2800000, type: .expense, categoryName: "Bills & Utilities", method: .bank, note: "Apartment Rent & Society Maintenance", daysAgo: 84, hour: 10, minute: 0),
            SampleItem(minorUnits: 4820000, type: .expense, categoryName: "Shopping", method: .card, note: "iPad Air & Smart Folio Case", daysAgo: 75, hour: 17, minute: 0),
        ]
        // swiftlint:enable line_length

        for item in samples {
            let baseDate = calendar.date(byAdding: .day, value: -item.daysAgo, to: now) ?? now
            let exactDate = calendar.date(bySettingHour: item.hour, minute: item.minute, second: 0, of: baseDate) ?? baseDate

            let cat = categoryMap[item.categoryName]
            let tx = Transaction(
                amountMinorUnits: item.minorUnits,
                type: item.type,
                date: exactDate,
                category: cat,
                paymentMethod: item.method,
                note: item.note
            )
            context.insert(tx)
        }
        try? context.save()
    }
}
