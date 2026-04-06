import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/services/auth_service.dart';
import 'core/services/biometric_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/widget_service.dart';
import 'features/expense/data/datasources/export_service.dart';
import 'features/expense/data/datasources/google_sheets_service.dart';
import 'features/expense/data/datasources/local_expense_datasource.dart';
import 'features/expense/data/repositories/expense_repository_impl.dart';
import 'features/expense/domain/repositories/expense_repository.dart';
import 'features/expense/domain/usecases/add_expense.dart';
import 'features/expense/domain/usecases/delete_expense.dart';
import 'features/expense/domain/usecases/get_expenses.dart';
import 'features/expense/domain/usecases/get_expenses_by_category.dart';
import 'features/expense/domain/usecases/update_expense.dart';
import 'features/expense/presentation/bloc/expense_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Core services
  getIt.registerLazySingleton(() => AuthService());
  getIt.registerLazySingleton(() => NotificationService());
  getIt.registerLazySingleton(() => ExportService());
  getIt.registerLazySingleton(() => BiometricService());
  getIt.registerLazySingleton(() => WidgetService());

  // Local data source
  getIt.registerLazySingleton(() => LocalExpenseDatasource());

  // Remote data source
  // GoogleSheetsService is registered at runtime after auth via registerGoogleSheetsService()

  // Repository
  getIt.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(
      sheetsService: getIt<GoogleSheetsService>(),
      localDatasource: getIt<LocalExpenseDatasource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetExpenses(getIt<ExpenseRepository>()));
  getIt.registerLazySingleton(() => AddExpense(getIt<ExpenseRepository>()));
  getIt.registerLazySingleton(() => UpdateExpense(getIt<ExpenseRepository>()));
  getIt.registerLazySingleton(() => DeleteExpense(getIt<ExpenseRepository>()));
  getIt.registerLazySingleton(() => GetExpensesByCategory(getIt<ExpenseRepository>()));

  // BLoC
  getIt.registerFactory(() => ExpenseBloc(
        getExpenses: getIt<GetExpenses>(),
        addExpense: getIt<AddExpense>(),
        updateExpense: getIt<UpdateExpense>(),
        deleteExpense: getIt<DeleteExpense>(),
        getExpensesByCategory: getIt<GetExpensesByCategory>(),
      ));

  // Initialize notifications
  await getIt<NotificationService>().initialize();
}

/// Call after successful Google Sign-In to register the sheets service.
void registerGoogleSheetsService(GoogleSheetsService service) {
  if (getIt.isRegistered<GoogleSheetsService>()) {
    getIt.unregister<GoogleSheetsService>();
  }
  getIt.registerSingleton<GoogleSheetsService>(service);
}
