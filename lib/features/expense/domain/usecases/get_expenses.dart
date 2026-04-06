import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class GetExpenses {
  final ExpenseRepository repository;

  GetExpenses(this.repository);

  Future<List<Expense>> call() {
    return repository.getExpenses();
  }

  Future<List<Expense>> byDateRange(DateTime start, DateTime end) {
    return repository.getExpensesByDateRange(start, end);
  }
}
