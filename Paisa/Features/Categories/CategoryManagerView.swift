//
//  CategoryManagerView.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI
import SwiftData

// MARK: - CategoryManagerView

struct CategoryManagerView: View {
    @Query(sort: \Category.sortOrder, order: .forward)
    private var allCategories: [Category]

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var showAddCategory: Bool = false
    @State private var categoryToEdit: Category? = nil

    private var activeCategories: [Category] { allCategories.filter { !$0.isArchived } }
    private var archivedCategories: [Category] { allCategories.filter { $0.isArchived } }

    var body: some View {
        NavigationStack {
            ZStack {
                PaisaColors.bgBase.ignoresSafeArea()

                List {
                    Section {
                        ForEach(activeCategories) { cat in
                            Button {
                                categoryToEdit = cat
                            } label: {
                                categoryRow(cat)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                if !cat.isDefault {
                                    Button {
                                        cat.isArchived = true
                                        try? modelContext.save()
                                    } label: {
                                        Label("Archive", systemImage: "archivebox")
                                    }
                                    .tint(.orange)
                                }
                            }
                            .listRowBackground(PaisaColors.bgCard)
                        }
                    } header: {
                        Text("Active · \(activeCategories.count)")
                            .font(PaisaFont.caption())
                            .foregroundStyle(PaisaColors.textSecondary)
                            .textCase(nil)
                    }

                    if !archivedCategories.isEmpty {
                        Section {
                            ForEach(archivedCategories) { cat in
                                categoryRow(cat)
                                    .opacity(0.5)
                                    .swipeActions(edge: .leading) {
                                        Button {
                                            cat.isArchived = false
                                            try? modelContext.save()
                                        } label: {
                                            Label("Restore", systemImage: "arrow.uturn.backward")
                                        }
                                        .tint(PaisaColors.primary)
                                    }
                                    .listRowBackground(PaisaColors.bgCard)
                            }
                        } header: {
                            Text("Archived")
                                .font(PaisaFont.caption())
                                .foregroundStyle(PaisaColors.textSecondary)
                                .textCase(nil)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(PaisaColors.bgBase)
            }
            .navigationTitle("Categories")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(PaisaColors.bgBase, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(PaisaColors.textSecondary)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddCategory = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(PaisaColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showAddCategory) {
                AddCategoryView()
            }
            .sheet(item: $categoryToEdit) { cat in
                AddCategoryView(editing: cat)
            }
        }
    }

    private func categoryRow(_ cat: Category) -> some View {
        HStack(spacing: PaisaSpacing.md) {
            PaisaIconBadge(
                icon: cat.icon,
                color: Color(hex: cat.colorHex),
                size: 40
            )
            VStack(alignment: .leading, spacing: 2) {
                Text(cat.name)
                    .font(PaisaFont.callout())
                    .foregroundStyle(PaisaColors.textPrimary)
                HStack(spacing: 4) {
                    PaisaTag(
                        text: cat.type == .expense ? "Expense" : cat.type == .income ? "Income" : "Both",
                        color: cat.type == .expense ? PaisaColors.expense : PaisaColors.income,
                        size: 10
                    )
                    if cat.isDefault {
                        PaisaTag(text: "Default", color: PaisaColors.neutral, size: 10)
                    }
                }
            }
            Spacer()
            let count = cat.transactions.count
            Text("\(count) \(count == 1 ? "tx" : "txs")")
                .font(PaisaFont.caption())
                .foregroundStyle(PaisaColors.textTertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - AddCategoryView

private let categoryIcons = [
    "fork.knife", "car.fill", "bag.fill", "bolt.fill", "heart.fill",
    "play.fill", "airplane", "book.fill", "sparkles", "house.fill",
    "phone.fill", "cart.fill", "music.note", "film.fill", "gamecontroller.fill",
    "gift.fill", "bandage.fill", "leaf.fill", "pawprint.fill", "dumbbell.fill",
    "graduationcap.fill", "briefcase.fill", "banknote.fill", "chart.line.uptrend.xyaxis",
    "indianrupeesign.circle.fill", "laptopcomputer", "building.columns", "cup.and.saucer.fill",
    "tshirt.fill", "bus.fill"
]

private let categoryColors = [
    "#FF6B6B", "#FF9F43", "#FFC048", "#A29BFE", "#6C5CE7",
    "#FD79A8", "#00CEC9", "#0984E3", "#00B894", "#E17055",
    "#636E72", "#2D3436", "#74B9FF", "#55EFC4", "#81ECEC",
    "#FDCB6E", "#E84393", "#6AB04C", "#EB4D4B", "#7ED6DF"
]

struct AddCategoryView: View {
    var editing: Category? = nil

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var selectedIcon: String = "tag.fill"
    @State private var selectedColor: String = "#A29BFE"
    @State private var selectedType: CategoryType = .expense

    init(editing: Category? = nil) {
        self.editing = editing
        if let cat = editing {
            _name          = State(initialValue: cat.name)
            _selectedIcon  = State(initialValue: cat.icon)
            _selectedColor = State(initialValue: cat.colorHex)
            _selectedType  = State(initialValue: cat.type)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PaisaColors.bgBase.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: PaisaSpacing.lg) {
                        // Preview badge
                        PaisaIconBadge(icon: selectedIcon, color: Color(hex: selectedColor), size: 72)
                            .padding(.top, PaisaSpacing.md)

                        // Name
                        TextField("Category Name", text: $name)
                            .font(PaisaFont.title3())
                            .foregroundStyle(PaisaColors.textPrimary)
                            .tint(PaisaColors.primary)
                            .multilineTextAlignment(.center)
                            .padding(PaisaSpacing.md)
                            .background(PaisaColors.bgCard)
                            .clipShape(RoundedRectangle(cornerRadius: PaisaRadius.md, style: .continuous))

                        // Type
                        Picker("Type", selection: $selectedType) {
                            Text("Expense").tag(CategoryType.expense)
                            Text("Income").tag(CategoryType.income)
                            Text("Both").tag(CategoryType.both)
                        }
                        .pickerStyle(.segmented)
                        .tint(PaisaColors.primary)

                        // Icon picker
                        VStack(alignment: .leading, spacing: PaisaSpacing.sm) {
                            Text("Icon")
                                .font(PaisaFont.caption())
                                .foregroundStyle(PaisaColors.textSecondary)
                                .textCase(.uppercase)
                                .tracking(1)

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 52))], spacing: PaisaSpacing.sm) {
                                ForEach(categoryIcons, id: \.self) { icon in
                                    Button {
                                        selectedIcon = icon
                                    } label: {
                                        Image(systemName: icon)
                                            .font(.system(size: 20))
                                            .foregroundStyle(
                                                selectedIcon == icon ? .white : Color(hex: selectedColor)
                                            )
                                            .frame(width: 48, height: 48)
                                            .background(
                                                selectedIcon == icon
                                                ? Color(hex: selectedColor)
                                                : Color(hex: selectedColor).opacity(0.15)
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .paisaCard()

                        // Color picker
                        VStack(alignment: .leading, spacing: PaisaSpacing.sm) {
                            Text("Colour")
                                .font(PaisaFont.caption())
                                .foregroundStyle(PaisaColors.textSecondary)
                                .textCase(.uppercase)
                                .tracking(1)

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: PaisaSpacing.sm) {
                                ForEach(categoryColors, id: \.self) { hex in
                                    Button {
                                        selectedColor = hex
                                    } label: {
                                        Circle()
                                            .fill(Color(hex: hex))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Circle()
                                                    .stroke(.white, lineWidth: selectedColor == hex ? 3 : 0)
                                            )
                                            .shadow(color: Color(hex: hex).opacity(0.5), radius: selectedColor == hex ? 6 : 0)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .paisaCard()

                        // Save
                        Button {
                            saveCategory()
                        } label: {
                            Text(editing == nil ? "Create Category" : "Save Changes")
                                .font(PaisaFont.headline())
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background {
                                    if name.trimmingCharacters(in: .whitespaces).isEmpty {
                                        PaisaColors.bgCard
                                    } else {
                                        LinearGradient(
                                            colors: [PaisaColors.primary, Color(hex: "#00E5A5")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: PaisaRadius.lg, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                        .padding(.bottom, PaisaSpacing.xl)
                    }
                    .padding(.horizontal, PaisaSpacing.md)
                }
            }
            .navigationTitle(editing == nil ? "New Category" : "Edit Category")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(PaisaColors.bgBase, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(PaisaColors.textSecondary)
                }
            }
        }
    }

    private func saveCategory() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        if let cat = editing {
            cat.name      = trimmed
            cat.icon      = selectedIcon
            cat.colorHex  = selectedColor
            cat.type      = selectedType
        } else {
            let cat = Category(
                name: trimmed,
                icon: selectedIcon,
                colorHex: selectedColor,
                type: selectedType
            )
            modelContext.insert(cat)
        }
        try? modelContext.save()
        dismiss()
    }
}
