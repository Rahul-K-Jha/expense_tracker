import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class GetExpensesByCategory {
  final ExpenseRepository repository;

  GetExpensesByCategory(this.repository);

  Future<List<Expense>> call(String categoryId) {
    return repository.getExpensesByCategory(categoryId);
  }
}
