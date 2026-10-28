//
//  AddTransactionView.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI
import SwiftData

// MARK: - AddTransactionView

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Category.sortOrder, order: .forward)
    private var allCategories: [Category]

    var editingTransaction: Transaction?
    var lastTransaction: Transaction?

    @State private var viewModel: AddTransactionViewModel
    @FocusState private var amountFocused: Bool

    init(editingTransaction: Transaction? = nil, lastTransaction: Transaction? = nil) {
        self.editingTransaction = editingTransaction
        self.lastTransaction    = lastTransaction
        _viewModel = State(initialValue: AddTransactionViewModel(
            editing: editingTransaction,
            lastTransaction: lastTransaction
        ))
    }

    private var filteredCategories: [Category] {
        allCategories.filter { cat in
            !cat.isArchived &&
            (cat.type == viewModel.selectedType || cat.type == .both)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PaisaColors.bgBase.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: PaisaSpacing.lg) {

                        // Type selector (income / expense pill)
                        typeSelectorPill

                        // Amount input
                        amountInputCard

                        // Category picker
                        categorySection

                        // Date & Payment method
                        dateAndPaymentSection

                        // Note field
                        noteSection

                        // Save button
                        saveButton
                            .padding(.bottom, PaisaSpacing.xl)
                    }
                    .padding(.horizontal, PaisaSpacing.md)
                    .padding(.top, PaisaSpacing.sm)
                }
            }
            .navigationTitle(editingTransaction == nil ? "Add Transaction" : "Edit Transaction")
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
            .alert("Invalid Input", isPresented: $viewModel.showValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.validationMessage)
            }
            .sheet(isPresented: $viewModel.showCategoryPicker) {
                CategoryPickerView(
                    categories: filteredCategories,
                    selected: $viewModel.selectedCategory
                )
            }
        }
        .onAppear { amountFocused = true }
    }

    // MARK: - Type Selector

    private var typeSelectorPill: some View {
        HStack(spacing: 0) {
            ForEach(TransactionType.allCases, id: \.rawValue) { type in
                Button {
                    withAnimation(.spring(duration: 0.25)) {
                        viewModel.selectedType = type
                        viewModel.selectedCategory = nil // reset on type change
                    }
                } label: {
                    Text(type == .expense ? "Expense" : "Income")
                        .font(PaisaFont.headline())
                        .foregroundStyle(
                            viewModel.selectedType == type ? .black : PaisaColors.textSecondary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            viewModel.selectedType == type
                            ? (type == .expense ? PaisaColors.expense : PaisaColors.income)
                            : Color.clear
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(PaisaColors.bgCard)
        .clipShape(Capsule())
    }

    // MARK: - Amount Input

    private var amountInputCard: some View {
        VStack(spacing: PaisaSpacing.sm) {
            Text("Amount")
                .font(PaisaFont.caption())
                .foregroundStyle(PaisaColors.textSecondary)
                .textCase(.uppercase)
                .tracking(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("₹")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(PaisaColors.textTertiary)

                TextField("0", text: $viewModel.amountString)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        viewModel.selectedType == .expense ? PaisaColors.expense : PaisaColors.income
                    )
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                    .focused($amountFocused)
                    .submitLabel(.done)
                    .tint(PaisaColors.primary)
            }
        }
        .paisaCard()
    }

    // MARK: - Category

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: PaisaSpacing.sm) {
            Text("Category")
                .font(PaisaFont.caption())
                .foregroundStyle(PaisaColors.textSecondary)
                .textCase(.uppercase)
                .tracking(1)

            // Quick horizontal scroll of recent categories
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PaisaSpacing.sm) {
                    ForEach(filteredCategories.prefix(8)) { cat in
                        Button {
                            withAnimation(.spring(duration: 0.2)) {
                                viewModel.selectedCategory = cat
                            }
                        } label: {
                            VStack(spacing: 4) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            viewModel.selectedCategory?.id == cat.id
                                            ? Color(hex: cat.colorHex)
                                            : Color(hex: cat.colorHex).opacity(0.18)
                                        )
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    viewModel.selectedCategory?.id == cat.id
                                                    ? Color(hex: cat.colorHex) : Color.clear,
                                                    lineWidth: 2
                                                )
                                        )

                                    Image(systemName: cat.icon)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(
                                            viewModel.selectedCategory?.id == cat.id
                                            ? .white : Color(hex: cat.colorHex)
                                        )
                                }

                                Text(cat.name.components(separatedBy: " ").first ?? cat.name)
                                    .font(PaisaFont.caption2())
                                    .foregroundStyle(
                                        viewModel.selectedCategory?.id == cat.id
                                        ? PaisaColors.textPrimary : PaisaColors.textSecondary
                                    )
                                    .lineLimit(1)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    // More button
                    Button {
                        viewModel.showCategoryPicker = true
                    } label: {
                        VStack(spacing: 4) {
                            Circle()
                                .fill(PaisaColors.bgCard)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "ellipsis")
                                        .font(.system(size: 18))
                                        .foregroundStyle(PaisaColors.textSecondary)
                                )
                            Text("More")
                                .font(PaisaFont.caption2())
                                .foregroundStyle(PaisaColors.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 4)
            }
        }
    }

    // MARK: - Date & Payment

    private var dateAndPaymentSection: some View {
        VStack(spacing: PaisaSpacing.sm) {
            // Date
            HStack {
                Label("Date", systemImage: "calendar")
                    .font(PaisaFont.callout())
                    .foregroundStyle(PaisaColors.textSecondary)
                Spacer()
                DatePicker(
                    "",
                    selection: $viewModel.selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .labelsHidden()
                .tint(PaisaColors.primary)
            }
            .padding(PaisaSpacing.md)
            .background(PaisaColors.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: PaisaRadius.md, style: .continuous))

            // Payment method
            VStack(alignment: .leading, spacing: PaisaSpacing.sm) {
                Label("Payment Method", systemImage: "creditcard")
                    .font(PaisaFont.callout())
                    .foregroundStyle(PaisaColors.textSecondary)
                    .padding(.horizontal, PaisaSpacing.md)
                    .padding(.top, PaisaSpacing.md)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: PaisaSpacing.sm) {
                        ForEach(PaymentMethod.allCases, id: \.rawValue) { method in
                            Button {
                                viewModel.selectedPaymentMethod = method
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: method.icon)
                                        .font(.system(size: 13))
                                    Text(method.rawValue)
                                        .font(PaisaFont.callout())
                                }
                                .foregroundStyle(
                                    viewModel.selectedPaymentMethod == method
                                    ? .black : PaisaColors.textSecondary
                                )
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    viewModel.selectedPaymentMethod == method
                                    ? PaisaColors.primary : PaisaColors.bgBase
                                )
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, PaisaSpacing.md)
                    .padding(.bottom, PaisaSpacing.md)
                }
            }
            .background(PaisaColors.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: PaisaRadius.md, style: .continuous))
        }
    }

    // MARK: - Note

    private var noteSection: some View {
        HStack(alignment: .top, spacing: PaisaSpacing.sm) {
            Image(systemName: "note.text")
                .font(.system(size: 16))
                .foregroundStyle(PaisaColors.textTertiary)
                .padding(.top, 2)

            TextField("Add a note (optional)", text: $viewModel.note, axis: .vertical)
                .font(PaisaFont.body())
                .foregroundStyle(PaisaColors.textPrimary)
                .tint(PaisaColors.primary)
                .lineLimit(3)
        }
        .paisaCard()
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            viewModel.save(context: modelContext, editing: editingTransaction)
            if !viewModel.showValidationError {
                dismiss()
            }
        } label: {
            HStack {
                Image(systemName: editingTransaction == nil ? "plus.circle.fill" : "checkmark.circle.fill")
                Text(editingTransaction == nil ? "Save Transaction" : "Update Transaction")
                    .font(PaisaFont.headline())
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                viewModel.isValid
                ? LinearGradient(
                    colors: [PaisaColors.primary, Color(hex: "#00E5A5")],
                    startPoint: .leading,
                    endPoint: .trailing
                  )
                : LinearGradient(
                    colors: [PaisaColors.bgCard, PaisaColors.bgCard],
                    startPoint: .leading,
                    endPoint: .trailing
                  )
            )
            .clipShape(RoundedRectangle(cornerRadius: PaisaRadius.lg, style: .continuous))
            .animation(.easeInOut(duration: 0.2), value: viewModel.isValid)
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.isValid)
        .glowEffect(
            color: viewModel.isValid ? PaisaColors.primary : .clear,
            radius: 14,
            opacity: 0.4
        )
    }
}

// MARK: - CategoryPickerView

struct CategoryPickerView: View {
    let categories: [Category]
    @Binding var selected: Category?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                PaisaColors.bgBase.ignoresSafeArea()

                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 90), spacing: PaisaSpacing.md)],
                        spacing: PaisaSpacing.md
                    ) {
                        ForEach(categories) { cat in
                            Button {
                                selected = cat
                                dismiss()
                            } label: {
                                VStack(spacing: PaisaSpacing.sm) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: cat.colorHex).opacity(0.2))
                                            .frame(width: 58, height: 58)
                                        Image(systemName: cat.icon)
                                            .font(.system(size: 24, weight: .semibold))
                                            .foregroundStyle(Color(hex: cat.colorHex))
                                    }
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                selected?.id == cat.id
                                                ? Color(hex: cat.colorHex) : Color.clear,
                                                lineWidth: 2
                                            )
                                    )

                                    Text(cat.name)
                                        .font(PaisaFont.caption())
                                        .foregroundStyle(PaisaColors.textPrimary)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(PaisaSpacing.sm)
                                .background(
                                    selected?.id == cat.id
                                    ? Color(hex: cat.colorHex).opacity(0.12) : PaisaColors.bgCard
                                )
                                .clipShape(RoundedRectangle(cornerRadius: PaisaRadius.md, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(PaisaSpacing.md)
                }
            }
            .navigationTitle("Select Category")
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
}

#Preview {
    AddTransactionView()
        .modelContainer(ModelContainerFactory.makePreviewContainer())
        .preferredColorScheme(.dark)
}
