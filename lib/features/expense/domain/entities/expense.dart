import 'package:equatable/equatable.dart';

import 'category.dart';
import 'payment_method.dart';

class Expense extends Equatable {
  final String id;
  final double amount;
  final Category category;
  final String description;
  final DateTime date;
  final PaymentMethod paymentMethod;
  final bool isRecurring;

  const Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.paymentMethod,
    this.isRecurring = false,
  });

  Expense copyWith({
    String? id,
    double? amount,
    Category? category,
    String? description,
    DateTime? date,
    PaymentMethod? paymentMethod,
    bool? isRecurring,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        category,
        description,
        date,
        paymentMethod,
        isRecurring,
      ];
}
