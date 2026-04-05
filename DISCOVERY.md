# Expense Tracker - Project Discovery & Analysis

**Date:** 2026-04-05
**Analyzed by:** Claude Code

---

## 1. Current Project State

### Architecture
- **Pattern:** Clean Architecture with feature-based folder structure
- **State Management:** BLoC (flutter_bloc v9.1.1)
- **DI:** get_it v8.0.3
- **Backend:** Google Sheets API (googleapis v14.0.0)
- **Local Storage:** shared_preferences v2.5.3

### Implemented (Done)
| Feature | Status | Notes |
|---------|--------|-------|
| Clean Architecture scaffold | Done | All folders, layers in place |
| Splash Screen | Done | Animated gradient + logo fade/scale |
| App Routing | Done | Named routes, Material 3 theme |
| BLoC Observer | Done | Debug logging for all bloc transitions |
| Google Sheets API service | Done | `getSheetNames()` method working |
| Sheet Selector UI | Partial | Dropdown exists, backend not wired |
| Dependency Injection container | Partial | Only DemoService registered |

### Planned (from README - Not Started)
| Feature | Status |
|---------|--------|
| Add, edit, delete expenses | Not started |
| Categorize expenses | Not started |
| View expense history & summaries | Not started |
| Google Sheets sync (full CRUD) | Not started |

### Future Improvements (from README)
| Feature | Status |
|---------|--------|
| Google Sign-In authentication | Not started |
| Data visualization (charts/graphs) | Not started |
| CSV/PDF export | Not started |
| Multi-user support | Not started |

### Known TODOs in Code
- `main.dart` - "TODO: Add Firebase Crashlytics"

### What's Missing from the Scaffold
All domain/data layers are empty directories with no actual files:
- No entities (Expense model, Category model)
- No use cases
- No repository interfaces or implementations
- No data models / DTOs
- BLoCs are empty scaffolds (no events, no states beyond base classes)

---

## 2. 2026 Expense Tracker Feature Landscape

Based on analysis of leading apps (Monarch, Copilot, SpendifiAI, Expensify, Rocket Money), here's what users expect in 2026:

### Must-Have Features
1. **AI-Powered Auto-Categorization** - ML-based transaction sorting (95%+ accuracy is the bar)
2. **Receipt Scanning (OCR)** - Camera capture, auto-extract amount/merchant/date
3. **Bank Sync via Plaid/Open Banking** - Real-time transaction import from 12,000+ banks
4. **Budget Management** - Category-based budgets with pace alerts ("you're spending too fast this month")
5. **Recurring Expense / Subscription Detection** - Auto-detect and flag subscriptions
6. **Multi-Currency Support** - Essential for global users
7. **Offline-First with Cloud Sync** - Works without internet, syncs when connected
8. **Biometric Auth** - Fingerprint/Face ID for app access
9. **Dark Mode** - Table stakes in 2026
10. **Push Notifications** - Budget alerts, bill reminders, spending anomalies

### Differentiating Features
11. **Predictive Spending Forecasts** - "You'll likely spend X this month based on patterns"
12. **Smart Savings Recommendations** - AI suggests where to cut spending
13. **Voice-Activated Transaction Logging** - "Add 50 dollars for groceries"
14. **Spending Insights Dashboard** - Daily/weekly/monthly trends with charts
15. **Goal Tracking** - Save for vacation, emergency fund, etc.
16. **Tax Category Tagging** - Mark deductible expenses for tax season
17. **Shared Expenses / Split Bills** - Collaborative expense tracking
18. **CSV/PDF Export** - Already planned; essential for tax/accounting

### Emerging / Premium Features
19. **AI Chat Assistant** - "How much did I spend on food last month?"
20. **Net Worth Tracking** - Combine expenses with assets/investments
21. **Geo-Tagged Expenses** - Track where you spend (map view)
22. **Behavioral Nudges** - Psychology-based interventions for overspending
23. **Widget Support** - Home screen widgets showing daily spend / budget remaining

---

## 3. Gap Analysis: Current vs. 2026 Standards

| Category | Current State | 2026 Expectation | Gap |
|----------|--------------|-------------------|-----|
| Data Entry | None | AI auto-categorize, OCR, voice | Critical |
| Storage | Google Sheets only | Offline-first + cloud sync | High |
| Categorization | Planned, not built | AI-powered, 95%+ accuracy | Critical |
| Analytics | None | Charts, trends, forecasts | High |
| Budgeting | None | Category budgets + pace alerts | High |
| Auth | None | Biometric + Google Sign-In | Medium |
| UI/UX | Splash + selector only | Full app with dark mode, widgets | Critical |
| Notifications | None | Budget alerts, bill reminders | Medium |
| Export | None | CSV, PDF | Low |
| Multi-user | None | Split bills, shared budgets | Low |

---

## 4. Recommended Feature Prioritization

### Phase 1: Core Foundation (Immediate Next Steps)
> Goal: Get a working expense tracker with basic CRUD

1. **Define Expense Entity** - id, amount, category, description, date, paymentMethod, isRecurring
2. **Define Category Entity** - id, name, icon, color, budget limit
3. **Implement Expense Repository** (abstract + Google Sheets impl)
4. **Implement Use Cases** - AddExpense, GetExpenses, UpdateExpense, DeleteExpense
5. **Wire up Expense BLoC** - Full event/state implementation
6. **Build Home Screen** - Expense list with daily/monthly grouping
7. **Build Add/Edit Expense Screen** - Form with category picker, date picker, amount input
8. **Complete Google Sheets CRUD** - Read, write, update, delete rows
9. **Wire DI container** - Register all repositories, use cases, blocs

### Phase 2: Usability & Polish
> Goal: Make it pleasant and practical for daily use

10. **Category Management** - Predefined + custom categories with icons/colors
11. **Dashboard Screen** - Monthly summary, top categories, spending chart
12. **Budget System** - Set monthly budget per category, track progress
13. **Dark Mode** - ThemeData for light/dark with system toggle
14. **Local Storage** - Cache expenses in SQLite/Hive for offline access
15. **Search & Filter** - By date range, category, amount range

### Phase 3: Intelligence & Delight
> Goal: Stand out with smart features

16. **Receipt Scanner** - Camera + Google ML Kit OCR
17. **AI Auto-Categorization** - On-device ML or API-based classification
18. **Spending Insights** - Weekly recap, trends, anomaly detection
19. **Push Notifications** - Budget alerts, bill reminders
20. **Recurring Expense Detection** - Auto-flag subscriptions
21. **CSV/PDF Export**

### Phase 4: Advanced
> Goal: Premium-tier features

22. **Google Sign-In Authentication**
23. **Biometric Lock**
24. **Voice Input** - Speech-to-expense
25. **Goal Tracking** - Savings goals with progress
26. **Multi-user / Split Bills**
27. **Home Screen Widgets**

---

## 5. Immediate Next Steps (Action Items)

These are the concrete tasks to start Phase 1 right now:

### Step 1: Define Domain Entities
```
lib/features/expense/domain/entities/
  - expense.dart          # Expense entity with Equatable
  - category.dart         # Category entity
  - payment_method.dart   # Enum: cash, card, UPI, etc.
```

### Step 2: Define Repository Contracts
```
lib/features/expense/domain/repositories/
  - expense_repository.dart   # Abstract: CRUD operations
```

### Step 3: Implement Use Cases
```
lib/features/expense/domain/usecases/
  - add_expense.dart
  - get_expenses.dart
  - update_expense.dart
  - delete_expense.dart
  - get_expenses_by_category.dart
```

### Step 4: Build Data Layer
```
lib/features/expense/data/
  models/
    - expense_model.dart       # DTO that maps to/from Google Sheets row
  repositories/
    - expense_repository_impl.dart  # Concrete impl using GoogleSheetsService
```

### Step 5: Wire Up BLoC
```
lib/features/expense/presentation/bloc/
  - expense_bloc.dart    # Handle: LoadExpenses, AddExpense, DeleteExpense, etc.
  - expense_event.dart   # All events
  - expense_state.dart   # Loading, Loaded, Error states
```

### Step 6: Build Screens
```
lib/features/expense/presentation/screens/
  - home_screen.dart           # Expense list + summary header
  - add_expense_screen.dart    # Form to add/edit expense
```

### Step 7: Register Dependencies
```
lib/injection.dart   # Register all repos, use cases, blocs in get_it
```

---

## 6. Technical Recommendations

| Decision | Recommendation | Why |
|----------|---------------|-----|
| Local DB | Hive or Isar | Fast, no-SQL, great for Flutter offline-first |
| Charts | fl_chart | Most customizable, actively maintained |
| OCR | google_mlkit_text_recognition | On-device, free, fast |
| Auth | firebase_auth + google_sign_in | Industry standard for Flutter |
| Notifications | flutter_local_notifications | Reliable, cross-platform |
| Date Handling | intl package | Already common in Flutter, good date formatting |
| Testing | bloc_test + mockito | Matches BLoC architecture |

---

## Sources
- [Best Expense Tracker Apps 2026 - PersonalFi.AI](https://www.personalfi.ai/research/best-expense-tracker-apps-2026)
- [Best Free Expense Trackers 2026 - SpendifiAI](https://www.spendifiai.com/blog/best-free-expense-trackers-2026)
- [Best Personal Expense Tracker Apps - Expensify](https://use.expensify.com/blog/personal-expense-tracker-apps)
- [Best Budget Apps 2026 - NerdWallet](https://www.nerdwallet.com/finance/learn/best-budget-apps)
- [AI Budgeting Tools - Cube Software](https://www.cubesoftware.com/blog/best-ai-budgeting-tools)
