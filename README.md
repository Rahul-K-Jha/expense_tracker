# Expense Tracker

This project is an **Expense Tracker** application designed to help users manage and monitor their daily expenses efficiently.

## Overview
- **Frontend:** Flutter (to be developed)
- **Backend/Storage:** Google Sheets (used as a database to store expense data)

## Architecture
This project follows the **Clean Architecture** pattern for scalable, testable, and maintainable code.

### Folder Structure
```
lib/
│
├── core/                        # Shared utilities, themes, etc.
│
├── features/
│   ├── expense/
│   │   ├── data/                # Data sources, models, repositories (implementation)
│   │   │   └── services/
│   │   │       └── google_sheets_service.dart
│   │   ├── domain/              # Entities, repositories (abstract), use cases
│   │   └── presentation/
│   │       ├── bloc/            # BLoC files for expense feature
│   │       │   ├── expense_bloc.dart
│   │       │   ├── expense_event.dart
│   │       │   └── expense_state.dart
│   │       └── screens/
│   │           └── splash_screen.dart
│   │
│   └── sheet_selector/
│       ├── data/
│       ├── domain/
│       └── presentation/
│           ├── bloc/            # BLoC files for sheet selector feature
│           │   ├── sheet_selector_bloc.dart
│           │   ├── sheet_selector_event.dart
│           │   └── sheet_selector_state.dart
│           └── screens/
│
└── main.dart
```

## Features (Planned)
- Add, edit, and delete expenses
- Categorize expenses
- View expense history and summaries
- Sync data with Google Sheets for persistent storage

## How It Works
1. **User Interface:**
   - The app provides a clean and intuitive UI built with Flutter for both Android and iOS platforms.
2. **Data Storage:**
   - All expense data is stored in a Google Sheet, allowing for easy access, backup, and sharing.
3. **Integration:**
   - The app uses Google Sheets API to read and write expense data securely.
4. **State Management:**
   - The app uses the BLoC pattern for state management, with each feature having its own BLoC under the `presentation/bloc/` folder.

## Getting Started
1. Clone this repository.
2. Set up your Flutter environment ([Flutter installation guide](https://flutter.dev/docs/get-started/install)).
3. Set up a Google Sheet and enable the Google Sheets API.
4. Configure API credentials for secure access.
5. Start building the Flutter frontend!

## Future Improvements
- Authentication (Google Sign-In)
- Data visualization (charts, graphs)
- Export data to CSV/PDF
- Multi-user support

## License
This project is open source and available under the [MIT License](LICENSE).

---

*Happy tracking your expenses!*
