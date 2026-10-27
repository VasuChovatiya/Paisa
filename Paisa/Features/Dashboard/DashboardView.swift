//
//  DashboardView.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI
import SwiftData
import Charts

// MARK: - DashboardView

struct DashboardView: View {
    @Query(sort: \Transaction.date, order: .reverse)
    private var allTransactions: [Transaction]

    @State private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: PaisaSpacing.lg) {

                    // Month navigator
                    PaisaMonthNavigator(selectedMonth: $viewModel.selectedMonth)
                        .padding(.top, PaisaSpacing.sm)

                    // Balance hero card
                    balanceHeroCard

                    // Income / expense summary row
                    summaryRow

                    // Spending trend chart
                    if let summary = viewModel.summary, !summary.transactions.isEmpty {
                        spendingTrendCard(summary: summary)
                    }

                    // Recent transactions
                    recentTransactionsSection
                }
                .padding(.horizontal, PaisaSpacing.md)
                .padding(.bottom, PaisaSpacing.tabBarClearance)
            }
            .background(PaisaColors.bgBase.ignoresSafeArea())
            .navigationTitle("Paisa")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(PaisaColors.bgBase, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            #endif
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SearchView()
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(PaisaColors.textPrimary)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddTransaction, onDismiss: {
                viewModel.refresh(transactions: allTransactions)
            }) {
                AddTransactionView(lastTransaction: allTransactions.first)
            }
            .sheet(item: $viewModel.transactionToEdit, onDismiss: {
                viewModel.refresh(transactions: allTransactions)
            }) { tx in
                AddTransactionView(editingTransaction: tx)
            }
        }
        .onChange(of: allTransactions) { _, new in
            viewModel.refresh(transactions: new)
        }
        .onChange(of: viewModel.selectedMonth) { _, _ in
            viewModel.refresh(transactions: allTransactions)
        }
        .onAppear {
            viewModel.refresh(transactions: allTransactions)
        }
    }

    // MARK: - Balance Hero Card

    private var balanceHeroCard: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#0D2B1F"), Color(hex: "#0D1A2E")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Decorative circles
            Circle()
                .fill(PaisaColors.primary.opacity(0.08))
                .frame(width: 200, height: 200)
                .offset(x: 80, y: -60)

            Circle()
                .fill(Color(hex: "#0984E3").opacity(0.06))
                .frame(width: 150, height: 150)
                .offset(x: -70, y: 60)

            VStack(spacing: PaisaSpacing.sm) {
                Text(viewModel.isCurrentMonth ? "This Month's Balance" : viewModel.selectedMonth.monthYearString)
                    .font(PaisaFont.caption())
                    .foregroundStyle(PaisaColors.textSecondary)
                    .textCase(.uppercase)
                    .tracking(1.2)

                let balance = viewModel.summary?.netBalanceMinorUnits ?? 0
                Text(PaisaFormatter.currency(minorUnits: abs(balance)))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(balance >= 0 ? PaisaColors.income : PaisaColors.expense)

                if balance < 0 {
                    PaisaTag(text: "Over budget", color: PaisaColors.expense)
                } else {
                    PaisaTag(text: "Savings", color: PaisaColors.income)
                }
            }
            .padding(.vertical, PaisaSpacing.xl)
        }
        .clipShape(RoundedRectangle(cornerRadius: PaisaRadius.xl, style: .continuous))
        .glowEffect(
            color: (viewModel.summary?.netBalanceMinorUnits ?? 0) >= 0 ? PaisaColors.income : PaisaColors.expense,
            radius: 20,
            opacity: 0.2
        )
    }

    // MARK: - Summary Row

    private var summaryRow: some View {
        HStack(spacing: PaisaSpacing.sm) {
            SummaryCard(
                title: "Income",
                amount: viewModel.summary?.totalIncome ?? 0,
                icon: "arrow.down.circle.fill",
                color: PaisaColors.income
            )
            SummaryCard(
                title: "Expenses",
                amount: viewModel.summary?.totalExpense ?? 0,
                icon: "arrow.up.circle.fill",
                color: PaisaColors.expense
            )
        }
    }

    // MARK: - Spending Trend Chart

    private func spendingTrendCard(summary: MonthlySummary) -> some View {
        let dailyData = summary.dailyBreakdown
        let hasData = dailyData.contains { $0.expenseMinorUnits > 0 }

        return VStack(alignment: .leading, spacing: PaisaSpacing.md) {
            Text("Daily Spending")
                .font(PaisaFont.title3())
                .foregroundStyle(PaisaColors.textPrimary)

            if hasData {
                Chart(dailyData) { day in
                    BarMark(
                        x: .value("Day", day.date, unit: .day),
                        y: .value("Amount", day.expenseMinorUnits)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [PaisaColors.expense, PaisaColors.expense.opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(4)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                        AxisGridLine(stroke: StrokeStyle(dash: [4]))
                            .foregroundStyle(PaisaColors.textTertiary.opacity(0.3))
                        AxisValueLabel(format: .dateTime.day(), centered: true)
                            .foregroundStyle(PaisaColors.textTertiary)
                            .font(PaisaFont.caption())
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine(stroke: StrokeStyle(dash: [4]))
                            .foregroundStyle(PaisaColors.textTertiary.opacity(0.3))
                        AxisValueLabel {
                            if let v = value.as(Int.self) {
                                Text("₹\(v / 100)")
                                    .font(PaisaFont.caption())
                                    .foregroundStyle(PaisaColors.textTertiary)
                            }
                        }
                    }
                }
                .frame(height: 140)
            } else {
                Text("No expenses recorded this month")
                    .font(PaisaFont.body())
                    .foregroundStyle(PaisaColors.textTertiary)
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
            }
        }
        .paisaCard()
    }

    // MARK: - Recent Transactions

    @Environment(\.modelContext) private var modelContext

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: PaisaSpacing.md) {
            HStack {
                Text("Recent Transactions")
                    .font(PaisaFont.title3())
                    .foregroundStyle(PaisaColors.textPrimary)
                Spacer()
                if !(viewModel.summary?.transactions.isEmpty ?? true) {
                    NavigationLink("See all") {
                        TransactionListView(month: viewModel.selectedMonth)
                    }
                    .font(PaisaFont.callout())
                    .foregroundStyle(PaisaColors.primary)
                }
            }

            if viewModel.recentTransactions.isEmpty {
                PaisaEmptyState(
                    icon: "tray",
                    title: "No transactions yet",
                    subtitle: "Tap + Add to record your first transaction"
                )
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.recentTransactions) { tx in
                        Button {
                            viewModel.transactionToEdit = tx
                        } label: {
                            TransactionRow(transaction: tx)
                                .padding(.vertical, PaisaSpacing.sm)
                        }
                        .buttonStyle(.plain)

                        if tx.id != viewModel.recentTransactions.last?.id {
                            Divider()
                                .background(PaisaColors.textTertiary.opacity(0.2))
                        }
                    }
                }
                .paisaCard()
            }
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(ModelContainerFactory.makePreviewContainer())
        .preferredColorScheme(.dark)
}
