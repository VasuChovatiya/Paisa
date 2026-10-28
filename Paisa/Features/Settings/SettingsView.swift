//
//  SettingsView.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI
import SwiftData

// MARK: - SettingsView

struct SettingsView: View {
    @Query(sort: \Transaction.date, order: .forward)
    private var allTransactions: [Transaction]

    @Query(sort: \Category.sortOrder, order: .forward)
    private var allCategories: [Category]

    @Environment(\.modelContext) private var modelContext

    @AppStorage("currency_symbol") private var currencySymbol: String = "₹"
    @AppStorage("month_start_day")  private var monthStartDay: Int = 1

    @State private var showExportSheet: Bool = false
    @State private var exportURL: URL?
    @State private var showDeleteAlert: Bool = false
    @State private var showCategoryManager: Bool = false
    @State private var exportError: String?
    @State private var showDemoDataActionSheet: Bool = false
    @State private var showDemoDataLoadedAlert: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                PaisaColors.bgBase.ignoresSafeArea()

                List {

                    // MARK: Data Section
                    Section {
                        Button {
                            performExport()
                        } label: {
                            settingsRow(
                                icon: "arrow.up.doc.fill",
                                iconColor: PaisaColors.primary,
                                title: "Export as CSV",
                                subtitle: "\(allTransactions.count) transactions"
                            )
                        }
                        .buttonStyle(.plain)
                    } header: {
                        sectionHeader("Data")
                    }

                    // MARK: Categories
                    Section {
                        Button {
                            showCategoryManager = true
                        } label: {
                            settingsRow(
                                icon: "tag.fill",
                                iconColor: Color(hex: "#A29BFE"),
                                title: "Manage Categories",
                                subtitle: "\(allCategories.filter { !$0.isArchived }.count) active"
                            )
                        }
                        .buttonStyle(.plain)
                    } header: {
                        sectionHeader("Preferences")
                    }

                    // MARK: Privacy
                    Section {
                        settingsRow(
                            icon: "lock.shield.fill",
                            iconColor: Color(hex: "#00B894"),
                            title: "Privacy",
                            subtitle: "All data stored on your device only"
                        )

                        settingsRow(
                            icon: "externaldrive.fill",
                            iconColor: Color(hex: "#0984E3"),
                            title: "Storage",
                            subtitle: "Offline-first · No cloud sync"
                        )
                    } header: {
                        sectionHeader("About")
                    }

                    // MARK: Danger Zone
                    Section {
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            settingsRow(
                                icon: "trash.fill",
                                iconColor: PaisaColors.expense,
                                title: "Delete All Data",
                                subtitle: "This cannot be undone"
                            )
                        }
                        .buttonStyle(.plain)
                    } header: {
                        sectionHeader("Danger Zone")
                    }

                    // MARK: App info
                    Section {
                        HStack {
                            Spacer()
                            VStack(spacing: 4) {
                                Text("Paisa")
                                    .font(PaisaFont.headline())
                                    .foregroundStyle(PaisaColors.textPrimary)
                                Text("Personal Expense Tracker")
                                    .font(PaisaFont.caption())
                                    .foregroundStyle(PaisaColors.textTertiary)
                                Text("v1.0 · Privacy-first · Made in India 🇮🇳")
                                    .font(PaisaFont.caption())
                                    .foregroundStyle(PaisaColors.textTertiary)
                            }
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                        .padding(.bottom, PaisaSpacing.tabBarClearance)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(PaisaColors.bgBase)
            }
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(PaisaColors.bgBase, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            #endif
            .sheet(isPresented: $showExportSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                        .presentationDetents([.medium])
                }
            }
            .sheet(isPresented: $showCategoryManager) {
                CategoryManagerView()
            }
            .confirmationDialog("Delete All Data", isPresented: $showDeleteAlert, titleVisibility: .visible) {
                Button("Delete Everything", role: .destructive) { deleteAllData() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("All \(allTransactions.count) transactions will be permanently deleted.")
            }
            .confirmationDialog("Load Demo Data", isPresented: $showDemoDataActionSheet, titleVisibility: .visible) {
                Button("Replace All with Demo Data", role: .destructive) {
                    loadDemoData(clearExisting: true)
                }
                Button("Add Demo Transactions") {
                    loadDemoData(clearExisting: false)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Choose whether to replace existing data or add demo transactions alongside your current transactions.")
            }
            .alert("Export Failed", isPresented: .init(
                get: { exportError != nil },
                set: { if !$0 { exportError = nil } }
            )) {
                Button("OK", role: .cancel) { exportError = nil }
            } message: {
                Text(exportError ?? "")
            }
            .alert("Demo Data Loaded", isPresented: $showDemoDataLoadedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Realistic sample transactions across multiple categories and months have been populated.")
            }
        }
    }

    // MARK: - Helpers

    private func settingsRow(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: PaisaSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(iconColor.opacity(0.18))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(PaisaFont.callout())
                    .foregroundStyle(PaisaColors.textPrimary)
                Text(subtitle)
                    .font(PaisaFont.caption())
                    .foregroundStyle(PaisaColors.textTertiary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(PaisaColors.textTertiary)
        }
        .padding(.vertical, 4)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(PaisaFont.caption())
            .foregroundStyle(PaisaColors.textTertiary)
            .textCase(.uppercase)
            .tracking(1)
    }

    private func performExport() {
        do {
            let url = try CSVExportService.writeToTemporaryFile(from: allTransactions)
            exportURL = url
            showExportSheet = true
        } catch {
            exportError = error.localizedDescription
        }
    }

    private func deleteAllData() {
        for tx in allTransactions { modelContext.delete(tx) }
        try? modelContext.save()
    }

    private func loadDemoData(clearExisting: Bool) {
        ModelContainerFactory.seedSampleTransactions(in: modelContext, clearExisting: clearExisting)
        showDemoDataLoadedAlert = true
    }
}

// MARK: - ShareSheet (UIKit bridge)

#if os(iOS)
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#elseif os(macOS)
import AppKit

struct ShareSheet: NSViewRepresentable {
    let items: [Any]

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            let picker = NSSharingServicePicker(items: items)
            picker.show(relativeTo: view.bounds, of: view, preferredEdge: .minY)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
#endif

#Preview {
    SettingsView()
        .modelContainer(ModelContainerFactory.makePreviewContainer())
        .preferredColorScheme(.dark)
}
