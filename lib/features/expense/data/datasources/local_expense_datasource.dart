import 'package:hive/hive.dart';

import '../models/expense_model.dart';

class LocalExpenseDatasource {
  static const _boxName = 'expenses';

  Future<Box<Map>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<Map>(_boxName);
    }
    return Hive.openBox<Map>(_boxName);
  }

  Future<List<ExpenseModel>> getAll() async {
    final box = await _openBox();
    return box.values
        .map((map) {
          final row = [
            map['id'],
            map['amount'],
            map['categoryId'],
            map['description'],
            map['date'],
            map['paymentMethod'],
            map['isRecurring'],
          ];
          return ExpenseModel.fromSheetRow(row);
        })
        .toList();
  }

  Future<void> saveAll(List<ExpenseModel> expenses) async {
    final box = await _openBox();
    await box.clear();
    for (final expense in expenses) {
      await box.put(expense.id, {
        'id': expense.id,
        'amount': expense.amount.toString(),
        'categoryId': expense.category.id,
        'description': expense.description,
        'date': expense.date.toIso8601String(),
        'paymentMethod': expense.paymentMethod.name,
        'isRecurring': expense.isRecurring.toString(),
      });
    }
  }

  Future<void> addExpense(ExpenseModel expense) async {
    final box = await _openBox();
    await box.put(expense.id, {
      'id': expense.id,
      'amount': expense.amount.toString(),
      'categoryId': expense.category.id,
      'description': expense.description,
      'date': expense.date.toIso8601String(),
      'paymentMethod': expense.paymentMethod.name,
      'isRecurring': expense.isRecurring.toString(),
    });
  }

  Future<void> deleteExpense(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  Future<void> clear() async {
    final box = await _openBox();
    await box.clear();
  }
}
