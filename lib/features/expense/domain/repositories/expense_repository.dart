import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses();
  Future<List<Expense>> getExpensesByCategory(String categoryId);
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end);
  Future<Expense> addExpense(Expense expense);
  Future<Expense> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);
}
