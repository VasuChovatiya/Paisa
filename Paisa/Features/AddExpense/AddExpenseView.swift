//
//  AddExpenseView.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI
import SwiftData

// MARK: - AddExpenseView

struct AddExpenseView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Category.sortOrder, order: .forward)
    private var allCategories: [Category]

    var onSaved: (() -> Void)? = nil

    @State private var amountString: String = ""
    @State private var selectedCategory: Category? = nil
    @State private var selectedPaymentMethod: PaymentMethod = .upi
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var showValidationError: Bool = false
    @State private var validationMessage: String = ""
    @State private var showSuccessFeedback: Bool = false

    @FocusState private var isAmountFocused: Bool

    private var expenseCategories: [Category] {
        allCategories.filter { cat in
            !cat.isArchived && (cat.type == .expense || cat.type == .both)
        }
    }

    private let quickAmounts: [Int] = [100, 200, 500, 1000, 2000]

    var body: some View {
        NavigationStack {
            ZStack {
                PaisaColors.bgBase.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: PaisaSpacing.lg) {
                        // Amount Card
                        amountCard

                        // Quick Amount Suggestions
                        quickAmountBar

                        // Category Selector
                        categoryGrid

                        // Payment & Date
                        paymentAndDateSection

                        // Note Input
                        noteSection

                        // Save Button
                        saveExpenseButton
                            .padding(.top, PaisaSpacing.sm)
                            .padding(.bottom, PaisaSpacing.xl)
                    }
                    .padding(.horizontal, PaisaSpacing.md)
                    .padding(.top, PaisaSpacing.sm)
                }
            }
            .navigationTitle("Add Expense")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(PaisaColors.bgBase, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            #endif
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reset") {
                        resetForm()
                    }
                    .font(PaisaFont.callout())
                    .foregroundStyle(PaisaColors.textSecondary)
                }
            }
            .alert("Invalid Input", isPresented: $showValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationMessage)
            }
            .overlay(alignment: .top) {
                if showSuccessFeedback {
                    successBanner
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .onAppear {
                if selectedCategory == nil {
                    selectedCategory = expenseCategories.first
                }
            }
        }
    }

    // MARK: - Amount Card

    private var amountCard: some View {
        VStack(spacing: PaisaSpacing.xs) {
            Text("ENTER AMOUNT")
                .font(PaisaFont.caption())
                .foregroundStyle(PaisaColors.textTertiary)
                .tracking(1.2)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("₹")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(PaisaColors.expense)

                TextField("0", text: $amountString)
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .foregroundStyle(PaisaColors.textPrimary)
                    .keyboardType(.decimalPad)
                    .focused($isAmountFocused)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, PaisaSpacing.sm)
        }
        .padding(PaisaSpacing.lg)
        .background(PaisaColors.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: PaisaRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: PaisaRadius.lg, style: .continuous)
                .stroke(PaisaColors.expense.opacity(0.25), lineWidth: 1)
        )
    }

    // MARK: - Quick Amounts

    private var quickAmountBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PaisaSpacing.sm) {
                ForEach(quickAmounts, id: \.self) { amt in
                    Button {
                        let current = Int(amountString) ?? 0
                        amountString = "\(current + amt)"
                    } label: {
                        Text("+₹\(amt)")
                            .font(PaisaFont.caption())
                            .foregroundStyle(PaisaColors.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(PaisaColors.bgSurface)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(PaisaColors.textTertiary.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Category Grid

    private var categoryGrid: some View {
        VStack(alignment: .leading, spacing: PaisaSpacing.sm) {
            Text("CATEGORY")
                .font(PaisaFont.caption())
                .foregroundStyle(PaisaColors.textTertiary)
                .tracking(1.2)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: PaisaSpacing.sm),
                    GridItem(.flexible(), spacing: PaisaSpacing.sm),
                    GridItem(.flexible(), spacing: PaisaSpacing.sm),
                    GridItem(.flexible(), spacing: PaisaSpacing.sm)
                ],
                spacing: PaisaSpacing.sm
            ) {
                ForEach(expenseCategories) { cat in
                    let isSelected = selectedCategory?.id == cat.id
                    Button {
                        withAnimation(.spring(duration: 0.2)) {
                            selectedCategory = cat
                        }
                    } label: {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: cat.colorHex).opacity(isSelected ? 0.35 : 0.15))
                                    .frame(width: 48, height: 48)

                                Image(systemName: cat.icon)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(Color(hex: cat.colorHex))
                            }
                            .overlay(
                                Circle()
                                    .stroke(
                                        isSelected ? Color(hex: cat.colorHex) : Color.clear,
                                        lineWidth: 2
                                    )
                            )

                            Text(cat.name)
                                .font(PaisaFont.caption())
                                .foregroundStyle(
                                    isSelected ? PaisaColors.textPrimary : PaisaColors.textSecondary
                                )
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                        .background(
                            isSelected
                            ? Color(hex: cat.colorHex).opacity(0.12)
                            : PaisaColors.bgSurface
                        )
                        .clipShape(RoundedRectangle(cornerRadius: PaisaRadius.md, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(PaisaSpacing.md)
        .background(PaisaColors.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: PaisaRadius.md, style: .continuous))
    }

    // MARK: - Payment & Date

    private var paymentAndDateSection: some View {
        VStack(spacing: PaisaSpacing.md) {
            // Payment method
            VStack(alignment: .leading, spacing: PaisaSpacing.sm) {
                Text("PAYMENT METHOD")
                    .font(PaisaFont.caption())
                    .foregroundStyle(PaisaColors.textTertiary)
                    .tracking(1.2)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: PaisaSpacing.xs) {
                        ForEach(PaymentMethod.allCases, id: \.rawValue) { method in
                            let isSelected = selectedPaymentMethod == method
                            Button {
                                selectedPaymentMethod = method
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: method.icon)
                                        .font(.system(size: 12))
                                    Text(method.rawValue)
                                        .font(PaisaFont.callout())
                                }
                                .foregroundStyle(isSelected ? .black : PaisaColors.textSecondary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(isSelected ? PaisaColors.primary : PaisaColors.bgBase)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            Divider()
                .overlay(PaisaColors.bgBase)

            // Date picker
            DatePicker(
                "Date",
                selection: $date,
                in: ...Date(),
                displayedComponents: [.date]
            )
            .font(PaisaFont.callout())
            .foregroundStyle(PaisaColors.textPrimary)
            .tint(PaisaColors.primary)
        }
        .padding(PaisaSpacing.md)
        .background(PaisaColors.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: PaisaRadius.md, style: .continuous))
    }

    // MARK: - Note Section

    private var noteSection: some View {
        HStack(alignment: .top, spacing: PaisaSpacing.sm) {
            Image(systemName: "note.text")
                .font(.system(size: 16))
                .foregroundStyle(PaisaColors.textTertiary)
                .padding(.top, 2)

            TextField("Add note or merchant name (optional)", text: $note)
                .font(PaisaFont.body())
                .foregroundStyle(PaisaColors.textPrimary)
                .tint(PaisaColors.primary)
        }
        .padding(PaisaSpacing.md)
        .background(PaisaColors.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: PaisaRadius.md, style: .continuous))
    }

    // MARK: - Save Button

    private var saveExpenseButton: some View {
        Button {
            saveExpense()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .bold))
                Text("Save Expense")
                    .font(PaisaFont.headline())
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: [PaisaColors.primary, Color(hex: "#00E5A5")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: PaisaRadius.md, style: .continuous))
            .shadow(color: PaisaColors.primary.opacity(0.35), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Success Banner

    private var successBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(PaisaColors.primary)
            Text("Expense saved successfully!")
                .font(PaisaFont.callout())
                .foregroundStyle(PaisaColors.textPrimary)
        }
        .padding(.horizontal, PaisaSpacing.lg)
        .padding(.vertical, PaisaSpacing.sm)
        .background(PaisaColors.bgSurface)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(PaisaColors.primary.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 10, y: 4)
        .padding(.top, 8)
    }

    // MARK: - Actions

    private func saveExpense() {
        let cleaned = amountString.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleaned.isEmpty else {
            validationMessage = "Please enter an amount."
            showValidationError = true
            return
        }

        guard let decimal = Decimal(string: cleaned), decimal > 0 else {
            validationMessage = "Amount must be a positive number."
            showValidationError = true
            return
        }

        // Convert to minor units (paise) safely
        let minorUnits = NSDecimalNumber(decimal: decimal * 100).intValue

        guard minorUnits > 0 else {
            validationMessage = "Amount is too small."
            showValidationError = true
            return
        }

        let newTransaction = Transaction(
            amountMinorUnits: minorUnits,
            type: .expense,
            date: date,
            category: selectedCategory,
            paymentMethod: selectedPaymentMethod,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        modelContext.insert(newTransaction)

        // Haptic feedback
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif

        withAnimation {
            showSuccessFeedback = true
        }

        resetForm()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation {
                showSuccessFeedback = false
            }
            onSaved?()
        }
    }

    private func resetForm() {
        amountString = ""
        note = ""
        date = Date()
        selectedPaymentMethod = .upi
        isAmountFocused = false
    }
}

#Preview {
    AddExpenseView()
        .modelContainer(ModelContainerFactory.makePreviewContainer())
        .preferredColorScheme(.dark)
}
