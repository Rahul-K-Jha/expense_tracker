import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

  // Local data source
  getIt.registerLazySingleton(() => LocalExpenseDatasource());

  // Remote data source
  // GoogleSheetsService requires runtime auth — register externally
  // after authentication is complete via:
  //   getIt.registerLazySingleton<GoogleSheetsService>(() => service);

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
}
