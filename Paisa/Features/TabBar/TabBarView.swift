//
//  TabBarView.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI
import SwiftData

// MARK: - TabBarView

struct TabBarView: View {
    @Query(sort: \Transaction.date, order: .reverse)
    private var allTransactions: [Transaction]

    @State private var selectedTab: Int = 0
    @State private var isShowingAddExpense: Bool = false

    private let tabs: [(icon: String, selectedIcon: String, title: String)] = [
        ("house", "house.fill", "Home"),
        ("chart.pie", "chart.pie.fill", "Insights"),
        ("gearshape", "gearshape.fill", "Settings")
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content
            Group {
                switch selectedTab {
                case 0:
                    DashboardView()
                case 1:
                    InsightsView()
                case 2:
                    SettingsView()
                default:
                    DashboardView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Floating Custom TabBar + Circular Action Button
            HStack(spacing: PaisaSpacing.md) {
                // Left Dock Pill
                tabsDock

                // Right Circular Add Button (in place of search)
                addButton
            }
            .padding(.horizontal, PaisaSpacing.lg)
            .padding(.bottom, 6)
        }
        .background(PaisaColors.bgBase.ignoresSafeArea())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $isShowingAddExpense) {
            AddTransactionView(lastTransaction: allTransactions.first)
        }
    }

    // MARK: - Tabs Dock (Floating Pill)

    private var tabsDock: some View {
        HStack(spacing: 4) {
            ForEach(0..<tabs.count, id: \.self) { index in
                let tab = tabs[index]
                let isSelected = selectedTab == index

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedTab = index
                    }
                    #if os(iOS)
                    let feedback = UISelectionFeedbackGenerator()
                    feedback.selectionChanged()
                    #endif
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                            .font(.system(size: 17, weight: isSelected ? .bold : .medium))
                            .foregroundStyle(isSelected ? PaisaColors.primary : PaisaColors.textSecondary)

                        Text(tab.title)
                            .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                            .foregroundStyle(isSelected ? PaisaColors.primary : PaisaColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        Group {
                            if isSelected {
                                Capsule()
                                    .fill(PaisaColors.bgSurface)
                                    .overlay(
                                        Capsule()
                                            .stroke(PaisaColors.primary.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.25), radius: 4, y: 2)
                            } else {
                                Color.clear
                            }
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .frame(height: 56)
        .background(PaisaColors.bgCard)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(PaisaColors.textTertiary.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 6)
    }

    // MARK: - Circular Add Button (FAB)

    private var addButton: some View {
        Button {
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            #endif
            isShowingAddExpense = true
        } label: {
            ZStack {
                Circle()
                    .fill(PaisaColors.bgCard)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(PaisaColors.textTertiary.opacity(0.18), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 6)

                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(PaisaColors.primary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Backwards compatibility alias
typealias MainTabView = TabBarView

#Preview {
    TabBarView()
        .modelContainer(ModelContainerFactory.makePreviewContainer())
        .preferredColorScheme(.dark)
}
