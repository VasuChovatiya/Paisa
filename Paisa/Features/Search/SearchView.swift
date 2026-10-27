//
//  SearchView.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI
import SwiftData

// MARK: - SearchTypeFilter

enum SearchTypeFilter: String, CaseIterable {
    case all     = "All"
    case expense = "Expenses"
    case income  = "Income"
}

// MARK: - SearchView

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Transaction.date, order: .reverse)
    private var allTransactions: [Transaction]

    @Query(sort: \Category.sortOrder, order: .forward)
    private var allCategories: [Category]

    @State private var searchText: String = ""
    @State private var selectedType: SearchTypeFilter = .all
    @State private var selectedCategoryId: UUID? = nil
    @State private var editingTransaction: Transaction? = nil

    private var activeCategories: [Category] {
        allCategories.filter { !$0.isArchived }
    }

    private var filteredTransactions: [Transaction] {
        allTransactions.filter { tx in
            // Type filter
            switch selectedType {
            case .all:
                break
            case .expense:
                guard tx.type == .expense else { return false }
            case .income:
                guard tx.type == .income else { return false }
            }

            // Category filter
            if let catId = selectedCategoryId {
                guard tx.category?.id == catId else { return false }
            }

            // Text search
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !query.isEmpty else { return true }

            let noteMatch = tx.note.lowercased().contains(query)
            let catMatch = tx.category?.name.lowercased().contains(query) ?? false
            let paymentMatch = tx.paymentMethod.rawValue.lowercased().contains(query)
            let amountString = PaisaFormatter.currency(tx.amount).lowercased()
            let amountMatch = amountString.contains(query)

            return noteMatch || catMatch || paymentMatch || amountMatch
        }
    }

    private var totalFilteredAmountPaise: Int {
        filteredTransactions.reduce(0) { sum, tx in
            sum + (tx.type == .expense ? -tx.amountMinorUnits : tx.amountMinorUnits)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PaisaColors.bgBase.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    searchBar
                        .padding(.horizontal, PaisaSpacing.md)
                        .padding(.top, PaisaSpacing.sm)
                        .padding(.bottom, PaisaSpacing.xs)

                    // Filters: Type pills + Category chips
                    filterSection
                        .padding(.bottom, PaisaSpacing.sm)

                    // Results List or Empty State
                    if filteredTransactions.isEmpty {
                        emptyStateView
                    } else {
                        resultsList
                    }
                }
            }
            .navigationTitle("Search")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(PaisaColors.bgBase, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            #endif
            .sheet(item: $editingTransaction) { tx in
                AddTransactionView(editingTransaction: tx)
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: PaisaSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(PaisaColors.textTertiary)
                .font(.system(size: 16, weight: .medium))

            TextField("Search notes, categories, amounts...", text: $searchText)
                .font(PaisaFont.body())
                .foregroundStyle(PaisaColors.textPrimary)
                .tint(PaisaColors.primary)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(PaisaColors.textTertiary)
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, PaisaSpacing.md)
        .padding(.vertical, PaisaSpacing.sm + 2)
        .background(PaisaColors.bgSurface)
        .clipShape(RoundedRectangle(cornerRadius: PaisaRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: PaisaRadius.md, style: .continuous)
                .stroke(PaisaColors.textTertiary.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        VStack(spacing: PaisaSpacing.xs) {
            // Type Filter Pills
            HStack(spacing: PaisaSpacing.xs) {
                ForEach(SearchTypeFilter.allCases, id: \.self) { type in
                    Button {
                        withAnimation(.spring(duration: 0.2)) {
                            selectedType = type
                        }
                    } label: {
                        Text(type.rawValue)
                            .font(PaisaFont.caption())
                            .foregroundStyle(selectedType == type ? .black : PaisaColors.textSecondary)
                            .padding(.horizontal, PaisaSpacing.md)
                            .padding(.vertical, 6)
                            .background(selectedType == type ? PaisaColors.primary : PaisaColors.bgCard)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                if selectedCategoryId != nil || selectedType != .all || !searchText.isEmpty {
                    Button {
                        withAnimation(.spring(duration: 0.2)) {
                            selectedType = .all
                            selectedCategoryId = nil
                            searchText = ""
                        }
                    } label: {
                        Text("Reset")
                            .font(PaisaFont.caption())
                            .foregroundStyle(PaisaColors.primary)
                    }
                    .padding(.trailing, PaisaSpacing.xs)
                }
            }
            .padding(.horizontal, PaisaSpacing.md)

            // Category Chips (Horizontal Scroll)
            if !activeCategories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: PaisaSpacing.xs) {
                        // "All Categories" chip
                        categoryChip(title: "All Categories", icon: "tray.2", isSelected: selectedCategoryId == nil) {
                            selectedCategoryId = nil
                        }

                        ForEach(activeCategories) { cat in
                            categoryChip(
                                title: cat.name,
                                icon: cat.icon,
                                color: Color(hex: cat.colorHex),
                                isSelected: selectedCategoryId == cat.id
                            ) {
                                if selectedCategoryId == cat.id {
                                    selectedCategoryId = nil
                                } else {
                                    selectedCategoryId = cat.id
                                }
                            }
                        }
                    }
                    .padding(.horizontal, PaisaSpacing.md)
                    .padding(.vertical, 2)
                }
            }
        }
    }

    private func categoryChip(
        title: String,
        icon: String,
        color: Color? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isSelected ? .black : (color ?? PaisaColors.textSecondary))

                Text(title)
                    .font(PaisaFont.caption())
                    .foregroundStyle(isSelected ? .black : PaisaColors.textSecondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isSelected ? PaisaColors.primary : PaisaColors.bgSurface)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : PaisaColors.textTertiary.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Results List

    private var resultsList: some View {
        VStack(spacing: 0) {
            // Summary row
            HStack {
                Text("\(filteredTransactions.count) transaction\(filteredTransactions.count == 1 ? "" : "s")")
                    .font(PaisaFont.caption())
                    .foregroundStyle(PaisaColors.textSecondary)

                Spacer()

                HStack(spacing: 4) {
                    Text("Net:")
                        .font(PaisaFont.caption())
                        .foregroundStyle(PaisaColors.textTertiary)

                    Text(PaisaFormatter.currency(minorUnits: abs(totalFilteredAmountPaise)))
                        .font(PaisaFont.mono(size: 12, weight: .semibold))
                        .foregroundStyle(
                            totalFilteredAmountPaise >= 0 ? PaisaColors.income : PaisaColors.expense
                        )
                }
            }
            .padding(.horizontal, PaisaSpacing.md)
            .padding(.vertical, PaisaSpacing.xs)

            List {
                ForEach(filteredTransactions) { tx in
                    TransactionRow(transaction: tx, showDate: true)
                        .listRowBackground(PaisaColors.bgSurface)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparatorTint(PaisaColors.bgCard)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingTransaction = tx
                        }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: PaisaSpacing.md) {
            Spacer()

            ZStack {
                Circle()
                    .fill(PaisaColors.bgSurface)
                    .frame(width: 80, height: 80)

                Image(systemName: "magnifyingglass")
                    .font(.system(size: 36))
                    .foregroundStyle(PaisaColors.textTertiary)
            }

            VStack(spacing: PaisaSpacing.xs) {
                Text(searchText.isEmpty ? "No Transactions Found" : "No Results for \"\(searchText)\"")
                    .font(PaisaFont.headline())
                    .foregroundStyle(PaisaColors.textPrimary)

                Text(
                    searchText.isEmpty
                    ? "Try adjusting your filters to find transactions."
                    : "Check your spelling or try searching for another note, category, or amount."
                )
                .font(PaisaFont.callout())
                .foregroundStyle(PaisaColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, PaisaSpacing.xl)
            }

            Spacer()
        }
    }
}

#Preview {
    SearchView()
        .modelContainer(ModelContainerFactory.makePreviewContainer())
        .preferredColorScheme(.dark)
}
