import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class AddExpense {
  final ExpenseRepository repository;

  AddExpense(this.repository);

  Future<Expense> call(Expense expense) {
    return repository.addExpense(expense);
  }
}
