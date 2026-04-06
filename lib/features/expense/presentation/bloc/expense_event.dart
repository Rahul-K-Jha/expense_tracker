import 'package:equatable/equatable.dart';

import '../../domain/entities/expense.dart';

abstract class ExpenseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {}

class AddExpenseEvent extends ExpenseEvent {
  final Expense expense;

  AddExpenseEvent(this.expense);

  @override
  List<Object?> get props => [expense];
}

class UpdateExpenseEvent extends ExpenseEvent {
  final Expense expense;

  UpdateExpenseEvent(this.expense);

  @override
  List<Object?> get props => [expense];
}

class DeleteExpenseEvent extends ExpenseEvent {
  final String id;

  DeleteExpenseEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class FilterByCategory extends ExpenseEvent {
  final String categoryId;

  FilterByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class FilterByDateRange extends ExpenseEvent {
  final DateTime start;
  final DateTime end;

  FilterByDateRange(this.start, this.end);

  @override
  List<Object?> get props => [start, end];
}
