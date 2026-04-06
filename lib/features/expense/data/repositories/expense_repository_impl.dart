import '../datasources/google_sheets_service.dart';
import '../datasources/local_expense_datasource.dart';
import '../models/expense_model.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final GoogleSheetsService sheetsService;
  final LocalExpenseDatasource localDatasource;
  final String sheetName;

  ExpenseRepositoryImpl({
    required this.sheetsService,
    required this.localDatasource,
    this.sheetName = 'Expenses',
  });

  @override
  Future<List<Expense>> getExpenses() async {
    try {
      await sheetsService.ensureHeaders(sheetName, ExpenseModel.sheetHeaders);
      final rows = await sheetsService.getRows(sheetName);
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
    await sheetsService.ensureHeaders(sheetName, ExpenseModel.sheetHeaders);
    final model = ExpenseModel.fromEntity(expense);
    await sheetsService.appendRow(sheetName, model.toSheetRow());
    await localDatasource.addExpense(model);
    return expense;
  }

  @override
  Future<Expense> updateExpense(Expense expense) async {
    final rowIndex = await _findRowIndex(expense.id);
    if (rowIndex == null) {
      throw Exception('Expense not found: ${expense.id}');
    }
    final model = ExpenseModel.fromEntity(expense);
    await sheetsService.updateRow(sheetName, rowIndex, model.toSheetRow());
    await localDatasource.addExpense(model); // overwrite in cache
    return expense;
  }

  @override
  Future<void> deleteExpense(String id) async {
    final rowIndex = await _findRowIndex(id);
    if (rowIndex == null) {
      throw Exception('Expense not found: $id');
    }
    await sheetsService.clearRow(sheetName, rowIndex);
    await localDatasource.deleteExpense(id);
  }

  Future<int?> _findRowIndex(String id) async {
    final rows = await sheetsService.getRows(sheetName);
    for (int i = 0; i < rows.length; i++) {
      if (rows[i].isNotEmpty && rows[i][0].toString() == id) {
        return i + 2;
      }
    }
    return null;
  }
}
