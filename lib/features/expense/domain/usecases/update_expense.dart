import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class UpdateExpense {
  final ExpenseRepository repository;

  UpdateExpense(this.repository);

  Future<Expense> call(Expense expense) {
    return repository.updateExpense(expense);
  }
}
