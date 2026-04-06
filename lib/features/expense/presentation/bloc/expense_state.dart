import 'package:equatable/equatable.dart';

import '../../domain/entities/expense.dart';

abstract class ExpenseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;
  final double totalAmount;

  ExpenseLoaded(this.expenses)
      : totalAmount = expenses.fold(0, (sum, e) => sum + e.amount);

  @override
  List<Object?> get props => [expenses, totalAmount];
}

class ExpenseError extends ExpenseState {
  final String message;

  ExpenseError(this.message);

  @override
  List<Object?> get props => [message];
}
