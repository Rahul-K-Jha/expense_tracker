import 'package:get_it/get_it.dart';

import '../datasources/google_sheets_service.dart';
import '../datasources/local_expense_datasource.dart';
import '../models/expense_model.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final LocalExpenseDatasource localDatasource;
  final String sheetName;

  ExpenseRepositoryImpl({
    required this.localDatasource,
    this.sheetName = 'Expenses',
  });

  /// Returns GoogleSheetsService if registered, null otherwise.
  GoogleSheetsService? get _sheetsService {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<GoogleSheetsService>()) {
      return getIt<GoogleSheetsService>();
    }
    return null;
  }

  @override
  Future<List<Expense>> getExpenses() async {
    final sheets = _sheetsService;
    if (sheets != null) {
      try {
        await sheets.ensureHeaders(sheetName, ExpenseModel.sheetHeaders);
        final rows = await sheets.getRows(sheetName);
        final expenses = rows
            .where((row) => row.isNotEmpty && row[0] != null && row[0].toString().isNotEmpty)
            .map((row) => ExpenseModel.fromSheetRow(row))
            .toList();

        // Cache to local storage
        await localDatasource.saveAll(expenses);
        return expenses;
      } catch (_) {
        // Fallback to local cache when offline
        return localDatasource.getAll();
      }
    }
    // No sheets service — offline only
    return localDatasource.getAll();
  }

  @override
  Future<List<Expense>> getExpensesByCategory(String categoryId) async {
    final expenses = await getExpenses();
    return expenses.where((e) => e.category.id == categoryId).toList();
  }

  @override
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final expenses = await getExpenses();
    return expenses
        .where((e) => !e.date.isBefore(start) && !e.date.isAfter(end))
        .toList();
  }

  @override
  Future<Expense> addExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);

    final sheets = _sheetsService;
    if (sheets != null) {
      try {
        await sheets.ensureHeaders(sheetName, ExpenseModel.sheetHeaders);
        await sheets.appendRow(sheetName, model.toSheetRow());
      } catch (_) {
        // Sheets failed — still save locally
      }
    }

    await localDatasource.addExpense(model);
    return expense;
  }

  @override
  Future<Expense> updateExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);

    final sheets = _sheetsService;
    if (sheets != null) {
      try {
        final rowIndex = await _findRowIndex(expense.id);
        if (rowIndex != null) {
          await sheets.updateRow(sheetName, rowIndex, model.toSheetRow());
        }
      } catch (_) {
        // Sheets failed — still update locally
      }
    }

    await localDatasource.addExpense(model);
    return expense;
  }

  @override
  Future<void> deleteExpense(String id) async {
    final sheets = _sheetsService;
    if (sheets != null) {
      try {
        final rowIndex = await _findRowIndex(id);
        if (rowIndex != null) {
          await sheets.clearRow(sheetName, rowIndex);
        }
      } catch (_) {
        // Sheets failed — still delete locally
      }
    }

    await localDatasource.deleteExpense(id);
  }

  Future<int?> _findRowIndex(String id) async {
    final sheets = _sheetsService;
    if (sheets == null) return null;

    final rows = await sheets.getRows(sheetName);
    for (int i = 0; i < rows.length; i++) {
      if (rows[i].isNotEmpty && rows[i][0].toString() == id) {
        return i + 2;
      }
    }
    return null;
  }
}
