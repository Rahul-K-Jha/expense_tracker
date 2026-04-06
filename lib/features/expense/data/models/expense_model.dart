import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/payment_method.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.amount,
    required super.category,
    required super.description,
    required super.date,
    required super.paymentMethod,
    super.isRecurring,
  });

  /// Column order in Google Sheet:
  /// [id, amount, categoryId, description, date, paymentMethod, isRecurring]
  factory ExpenseModel.fromSheetRow(List<Object?> row) {
    final categoryId = (row[2] ?? 'other').toString();
    final category = Category.defaults.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => Category.defaults.last,
    );

    return ExpenseModel(
      id: row[0].toString(),
      amount: double.tryParse(row[1].toString()) ?? 0.0,
      category: category,
      description: (row[3] ?? '').toString(),
      date: DateTime.tryParse(row[4].toString()) ?? DateTime.now(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (p) => p.name == (row[5] ?? 'cash').toString(),
        orElse: () => PaymentMethod.cash,
      ),
      isRecurring: (row[6] ?? 'false').toString().toLowerCase() == 'true',
    );
  }

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      amount: expense.amount,
      category: expense.category,
      description: expense.description,
      date: expense.date,
      paymentMethod: expense.paymentMethod,
      isRecurring: expense.isRecurring,
    );
  }

  List<Object> toSheetRow() {
    return [
      id,
      amount,
      category.id,
      description,
      date.toIso8601String(),
      paymentMethod.name,
      isRecurring.toString(),
    ];
  }

  static const List<String> sheetHeaders = [
    'ID',
    'Amount',
    'Category',
    'Description',
    'Date',
    'Payment Method',
    'Is Recurring',
  ];
}
