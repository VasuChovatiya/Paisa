# Paisa — Personal Expense Tracker

**iOS-first · SwiftUI · Offline-first · Privacy-first · India-ready**

## Stack

| Concern | Choice |
|---|---|
| UI | SwiftUI + `@Observable` |
| Data | SwiftData (iOS 17+) |
| Charts | Swift Charts |
| Architecture | MVVM |
| CSV Export | Foundation (no third-party) |
| Tests | XCTest |
| Deployment target | iOS 17.6+ |

## Project Layout

```
Paisa/
├── Paisa/
│   ├── MyApp.swift                        # @main entry point
│   ├── ContentView.swift                  # Root TabView
│   ├── Core/
│   │   ├── DesignSystem/
│   │   │   ├── DesignSystem.swift         # Colors, spacing, typography, formatter
│   │   │   └── Components.swift           # Reusable SwiftUI components
│   │   └── Extensions/
│   │       └── Extensions.swift           # Color, View, Date, Int helpers
│   ├── Data/
│   │   ├── Models/
│   │   │   ├── Transaction.swift          # SwiftData @Model
│   │   │   └── Category.swift             # SwiftData @Model + default seed
│   │   └── Persistence/
│   │       └── ModelContainerFactory.swift
│   ├── Services/
│   │   ├── ExpenseCalculator.swift        # Pure arithmetic (integer minor units)
│   │   ├── MonthlySummaryService.swift    # Monthly grouping & MoM comparison
│   │   └── CSVExportService.swift         # RFC 4180 CSV + injection protection
│   └── Features/
│       ├── Root/
│       │   └── RootView.swift
│       ├── Splash/
│       │   └── SplashView.swift
│       ├── TabBar/
│       │   └── TabBarView.swift
│       ├── Dashboard/
│       │   ├── DashboardView.swift
│       │   └── DashboardViewModel.swift
│       ├── Search/
│       │   └── SearchView.swift
│       ├── AddExpense/
│       │   └── AddExpenseView.swift
│       ├── Transactions/
│       │   ├── TransactionRow.swift
│       │   ├── TransactionListView.swift
│       │   ├── AddTransactionView.swift
│       │   └── AddTransactionViewModel.swift
│       ├── Insights/
│       │   └── InsightsView.swift
│       ├── Categories/
│       │   └── CategoryManagerView.swift
│       └── Settings/
│           └── SettingsView.swift
├── PaisaTests/
│   ├── ExpenseCalculatorTests.swift
│   ├── MonthlySummaryTests.swift
│   └── CSVExportServiceTests.swift
└── scripts/
    └── check-xcsset.sh
```

## Rules (from NATIVE_IOS_PROJECT_RULES.md)

- **SwiftUI only** — no UIKit, except `UIActivityViewController` bridge in `ShareSheet`
- **`@Observable`** — not `ObservableObject`
- **No force unwrapping** in SwiftUI code
- **Amounts stored as integer minor units** (paise) — never binary float
- **Financial calculations in Services** — never scattered across Views
- **Categories are archived, not deleted** — transaction history is preserved
- **CSV export protects against formula injection**
- Run `scripts/check-xcsset.sh` before every commit
- iOS 17.6+ deployment target
- SPM only (no CocoaPods)
- Git: Conventional Commits, no force-push to main

## Security

Run the XCSSET guard before committing:
```bash
bash scripts/check-xcsset.sh
```

## Financial Correctness

- All monetary amounts stored as `Int` minor units (paise): ₹125.50 → `12550`
- `ExpenseCalculator` is a pure function enum — no side effects
- Month boundaries use `Calendar.current` — transactions near midnight stay in their correct period
- Category deletion = archive → transactions retain their category reference
- One currency (INR) in v1

## Adding New Files

After adding Swift files, make sure to add them to the Xcode target (Build Phases → Compile Sources). The project uses `.xcodeproj` directly (no XcodeGen).
