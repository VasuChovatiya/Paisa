//
//  InsightsView.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI
import SwiftData
import Charts

// MARK: - InsightsView

struct InsightsView: View {
    @Query(sort: \Transaction.date, order: .reverse)
    private var allTransactions: [Transaction]

    @State private var selectedMonth: Date = Date()

    private var currentSummary: MonthlySummary {
        MonthlySummaryService.summary(for: selectedMonth, from: allTransactions)
    }

    private var previousSummary: MonthlySummary {
        MonthlySummaryService.summary(for: selectedMonth.addingMonths(-1), from: allTransactions)
    }

    private var monthChange: Double? {
        MonthlySummaryService.monthOverMonthChange(
            current: currentSummary,
            previous: previousSummary
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PaisaColors.bgBase.ignoresSafeArea()

                if allTransactions.isEmpty {
                    PaisaEmptyState(
                        icon: "chart.pie",
                        title: "No data yet",
                        subtitle: "Add some transactions to see insights"
                    )
                    .padding(.bottom, PaisaSpacing.tabBarClearance)
                } else {
                    ScrollView {
                        LazyVStack(spacing: PaisaSpacing.lg) {
                            PaisaMonthNavigator(selectedMonth: $selectedMonth)
                                .padding(.top, PaisaSpacing.sm)

                            // Month vs Month comparison card
                            monthComparisonCard

                            // Category breakdown
                            categoryBreakdownSection

                            // Top spending category highlight
                            if let top = currentSummary.categoryBreakdown.first {
                                topCategoryCard(top: top)
                            }
                        }
                        .padding(.horizontal, PaisaSpacing.md)
                        .padding(.bottom, PaisaSpacing.tabBarClearance)
                    }
                }
            }
            .navigationTitle("Insights")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(PaisaColors.bgBase, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            #endif
        }
    }

    // MARK: - Month Comparison

    private var monthComparisonCard: some View {
        VStack(alignment: .leading, spacing: PaisaSpacing.md) {
            Text("Month Overview")
                .font(PaisaFont.title3())
                .foregroundStyle(PaisaColors.textPrimary)

            HStack(spacing: PaisaSpacing.sm) {
                // This month
                VStack(alignment: .leading, spacing: 4) {
                    Text("This Month")
                        .font(PaisaFont.caption())
                        .foregroundStyle(PaisaColors.textTertiary)
                        .textCase(.uppercase)
                        .tracking(0.8)
                    Text(PaisaFormatter.currency(currentSummary.totalExpense))
                        .font(PaisaFont.mono(size: 18, weight: .bold))
                        .foregroundStyle(PaisaColors.expense)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()
                    .background(PaisaColors.textTertiary.opacity(0.3))
                    .frame(height: 40)

                // Last month
                VStack(alignment: .leading, spacing: 4) {
                    Text("Last Month")
                        .font(PaisaFont.caption())
                        .foregroundStyle(PaisaColors.textTertiary)
                        .textCase(.uppercase)
                        .tracking(0.8)
                    Text(PaisaFormatter.currency(previousSummary.totalExpense))
                        .font(PaisaFont.mono(size: 18, weight: .bold))
                        .foregroundStyle(PaisaColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Change badge
                if let change = monthChange {
                    VStack(spacing: 2) {
                        Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                            .font(.system(size: 12, weight: .bold))
                        Text("\(Int(abs(change) * 100))%")
                            .font(PaisaFont.caption2())
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(change >= 0 ? PaisaColors.expense : PaisaColors.income)
                    .frame(width: 52, height: 52)
                    .background(
                        (change >= 0 ? PaisaColors.expense : PaisaColors.income).opacity(0.15)
                    )
                    .clipShape(Circle())
                }
            }
        }
        .paisaCard()
    }

    // MARK: - Category Breakdown

    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: PaisaSpacing.md) {
            Text("Expense Breakdown")
                .font(PaisaFont.title3())
                .foregroundStyle(PaisaColors.textPrimary)

            let breakdown = currentSummary.categoryBreakdown

            if breakdown.isEmpty {
                PaisaEmptyState(
                    icon: "chart.pie",
                    title: "No expenses",
                    subtitle: "No expense transactions this month"
                )
            } else {
                // Donut chart
                let total = breakdown.reduce(0) { $0 + $1.totalMinorUnits }

                Chart(breakdown) { item in
                    SectorMark(
                        angle: .value("Amount", item.totalMinorUnits),
                        innerRadius: .ratio(0.60),
                        angularInset: 2
                    )
                    .foregroundStyle(Color(hex: item.category.colorHex))
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .chartLegend(.hidden)
                .overlay {
                    VStack(spacing: 2) {
                        Text("Total")
                            .font(PaisaFont.caption())
                            .foregroundStyle(PaisaColors.textTertiary)
                        Text(PaisaFormatter.currency(minorUnits: total))
                            .font(PaisaFont.mono(size: 15, weight: .bold))
                            .foregroundStyle(PaisaColors.textPrimary)
                    }
                }

                // Category list
                VStack(spacing: 0) {
                    ForEach(breakdown) { item in
                        categoryBreakdownRow(item: item, total: total)

                        if item.id != breakdown.last?.id {
                            Divider()
                                .background(PaisaColors.textTertiary.opacity(0.2))
                        }
                    }
                }
            }
        }
        .paisaCard()
    }

    private func categoryBreakdownRow(item: ExpenseCalculator.CategoryTotal, total: Int) -> some View {
        HStack(spacing: PaisaSpacing.md) {
            PaisaIconBadge(
                icon: item.category.icon,
                color: Color(hex: item.category.colorHex),
                size: 36
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(item.category.name)
                    .font(PaisaFont.callout())
                    .foregroundStyle(PaisaColors.textPrimary)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(PaisaColors.bgBase)
                            .frame(height: 4)
                        Capsule()
                            .fill(Color(hex: item.category.colorHex))
                            .frame(width: geo.size.width * item.percentage, height: 4)
                            .animation(.spring(duration: 0.5), value: item.percentage)
                    }
                }
                .frame(height: 4)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(PaisaFormatter.currency(item.amount))
                    .font(PaisaFont.mono(size: 13, weight: .semibold))
                    .foregroundStyle(PaisaColors.textPrimary)
                Text("\(Int(item.percentage * 100))%")
                    .font(PaisaFont.caption())
                    .foregroundStyle(PaisaColors.textTertiary)
            }
        }
        .padding(.vertical, PaisaSpacing.sm)
    }

    // MARK: - Top Category

    private func topCategoryCard(top: ExpenseCalculator.CategoryTotal) -> some View {
        HStack(spacing: PaisaSpacing.md) {
            PaisaIconBadge(
                icon: "flame.fill",
                color: PaisaColors.accent,
                size: 44
            )
            VStack(alignment: .leading, spacing: 4) {
                Text("Highest Spend")
                    .font(PaisaFont.caption())
                    .foregroundStyle(PaisaColors.textTertiary)
                    .textCase(.uppercase)
                    .tracking(0.8)
                Text(top.category.name)
                    .font(PaisaFont.headline())
                    .foregroundStyle(PaisaColors.textPrimary)
                Text("\(Int(top.percentage * 100))% of your expenses this month")
                    .font(PaisaFont.caption())
                    .foregroundStyle(PaisaColors.textSecondary)
            }
            Spacer()
            Text(PaisaFormatter.currency(top.amount))
                .font(PaisaFont.mono(size: 16, weight: .bold))
                .foregroundStyle(PaisaColors.expense)
        }
        .paisaCard()
    }
}

#Preview {
    InsightsView()
        .modelContainer(ModelContainerFactory.makePreviewContainer())
        .preferredColorScheme(.dark)
}
