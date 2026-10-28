//
//  TransactionListView.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI
import SwiftData

// MARK: - TransactionListView
// Full list of transactions for a given month, grouped by date.

struct TransactionListView: View {
    let month: Date

    @Query(sort: \Transaction.date, order: .reverse)
    private var allTransactions: [Transaction]

    @Environment(\.modelContext) private var modelContext
    @State private var transactionToEdit: Transaction?
    @State private var showDeleteConfirmation: Bool = false
    @State private var pendingDeleteTransaction: Transaction?

    private var filteredTransactions: [Transaction] {
        MonthlySummaryService.summary(
            for: month,
            from: allTransactions
        ).transactions.sorted { $0.date > $1.date }
    }

    // Group by calendar day
    private var groupedByDay: [(date: Date, transactions: [Transaction])] {
        var groups: [Date: [Transaction]] = [:]
        let calendar = Calendar.current

        for tx in filteredTransactions {
            let day = calendar.startOfDay(for: tx.date)
            groups[day, default: []].append(tx)
        }

        return groups
            .sorted { $0.key > $1.key }
            .map { (date: $0.key, transactions: $0.value) }
    }

    var body: some View {
        ZStack {
            PaisaColors.bgBase.ignoresSafeArea()

            if filteredTransactions.isEmpty {
                PaisaEmptyState(
                    icon: "tray",
                    title: "No transactions",
                    subtitle: "No transactions recorded for \(month.monthYearString)"
                )
            } else {
                List {
                    ForEach(groupedByDay, id: \.date) { group in
                        Section {
                            ForEach(group.transactions) { tx in
                                Button {
                                    transactionToEdit = tx
                                } label: {
                                    TransactionRow(transaction: tx)
                                }
                                .buttonStyle(.plain)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        pendingDeleteTransaction = tx
                                        showDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    .tint(PaisaColors.expense)

                                    Button {
                                        transactionToEdit = tx
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(PaisaColors.primary)
                                }
                                .listRowBackground(PaisaColors.bgCard)
                                .listRowSeparatorTint(PaisaColors.textTertiary.opacity(0.25))
                            }
                        } header: {
                            Text(group.date.transactionDisplayString)
                                .font(PaisaFont.caption())
                                .foregroundStyle(PaisaColors.textSecondary)
                                .textCase(nil)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(PaisaColors.bgBase)
            }
        }
        .navigationTitle(month.monthYearString)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(PaisaColors.bgBase, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        #endif
        .sheet(item: $transactionToEdit) { tx in
            AddTransactionView(editingTransaction: tx)
        }
        .confirmationDialog(
            "Delete Transaction",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let tx = pendingDeleteTransaction {
                    modelContext.delete(tx)
                    try? modelContext.save()
                }
                pendingDeleteTransaction = nil
            }
            Button("Cancel", role: .cancel) {
                pendingDeleteTransaction = nil
            }
        } message: {
            Text("This will permanently delete the transaction.")
        }
    }
}
