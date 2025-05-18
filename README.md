# Expense Tracker

This project is an **Expense Tracker** application designed to help users manage and monitor their daily expenses efficiently.

## Overview
- **Frontend:** Flutter (to be developed)
- **Backend/Storage:** Google Sheets (used as a database to store expense data)

## Architecture
This project follows the **Clean Architecture** pattern for scalable, testable, and maintainable code.

### SOLID Principles in Flutter Project Structure
This project structure is designed to adhere to the SOLID principles, ensuring maintainability and scalability:

**S - Single Responsibility Principle (SRP)**
- **Core Directory:** Each subdirectory in `/core` has a single responsibility (e.g., `/core/errors` for error classes, `/core/utils` for utilities, `/core/di` for dependency injection).
- **Feature Directory:** Each feature (e.g., `/features/expense`) separates concerns:
  - `/domain` for business logic and entities
  - `/data` for data handling
  - `/presentation` for UI and state management
- **Blocs:** Located in the presentation layer, each BLoC manages the state of a specific UI component.

**O - Open/Closed Principle (OCP)**
- **Entities:** Entities in `/domain` are open for extension but closed for modification.
- **Use Cases:** New business logic can be added as new use cases without modifying existing ones.
- **Repositories:** Abstract repositories in `/domain` and concrete implementations in `/data` allow new data sources or changes without affecting dependent code.

**L - Liskov Substitution Principle (LSP)**
- **Repository Implementations:** Any concrete repository in `/data` can substitute the abstract repository in `/domain` without breaking functionality.

**I - Interface Segregation Principle (ISP)**
- **Repository Interfaces:** The structure encourages focused repository interfaces in `/domain`, promoting small, specific interfaces rather than large, catch-all ones.

**D - Dependency Inversion Principle (DIP)**
- **Layered Architecture:**
  - High-level modules (use cases in `/domain`, blocs in `/presentation`) depend on abstractions (repository interfaces in `/domain`).
  - Low-level modules (data sources, repository implementations in `/data`) also depend on abstractions.
- **Dependency Injection:** The `/core/di` directory is dedicated to dependency injection, allowing dependencies to be injected and decoupling components.

### Folder Structure
```
lib/
  core/
    constants/        # Application-wide constants
    errors/           # Custom exception classes
    utils/            # Utility functions
    services/         # Core services (e.g., network, local storage)
    di/               # Dependency Injection setup
    widgets/          # Reusable widgets
  features/
    expense/          # Feature: Expense Tracking
      data/
        datasources/    # Implementations of data sources (remote, local)
          google_sheets_service.dart  # Google Sheets API integration
        models/         # Data Transfer Objects (DTOs) for API/database
        repositories/   # Implementations of repository interfaces
      domain/
        entities/       # Core business entities
        repositories/   # Abstract repository interfaces
        usecases/       # Business logic use cases
      presentation/
        bloc/           # Bloc for state management
        screens/        # UI screens/pages
        widgets/        # UI-specific widgets
    sheet_selector/   # Feature: Sheet Selection
      data/
        datasources/
        models/
        repositories/
      domain/
        entities/
        repositories/
        usecases/
      presentation/
        bloc/
        screens/
        widgets/
  configs/            # Configuration files
  main.dart           # Application entry point
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
