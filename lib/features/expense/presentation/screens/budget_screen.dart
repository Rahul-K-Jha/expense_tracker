import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_state.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ExpenseLoaded) {
            return _buildBudgetList(context, state.expenses);
          }
          return const Center(child: Text('Load expenses first'));
        },
      ),
    );
  }

  Widget _buildBudgetList(BuildContext context, List<Expense> expenses) {
    final now = DateTime.now();
    final monthExpenses = expenses.where(
      (e) => e.date.year == now.year && e.date.month == now.month,
    ).toList();

    final categorySpending = <String, double>{};
    for (final expense in monthExpenses) {
      categorySpending[expense.category.id] =
          (categorySpending[expense.category.id] ?? 0) + expense.amount;
    }

    final categories = Category.defaults
        .where((c) => c.budgetLimit != null)
        .toList();

    if (categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No budgets set',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Set budget limits on categories to track your spending',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final spent = categorySpending[category.id] ?? 0;
        final budget = category.budgetLimit!;
        final progress = (spent / budget).clamp(0.0, 1.0);
        final isOverBudget = spent > budget;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: category.color.withValues(alpha: 0.2),
                      child: Icon(category.icon, color: category.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isOverBudget)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Over budget',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    color: isOverBudget ? Colors.red : category.color,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\u20B9${spent.toStringAsFixed(2)} spent',
                      style: TextStyle(
                        color: isOverBudget ? Colors.red : Colors.grey,
                      ),
                    ),
                    Text(
                      '\u20B9${budget.toStringAsFixed(2)} budget',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                if (!isOverBudget) ...[
                  const SizedBox(height: 4),
                  Text(
                    '\u20B9${(budget - spent).toStringAsFixed(2)} remaining',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
