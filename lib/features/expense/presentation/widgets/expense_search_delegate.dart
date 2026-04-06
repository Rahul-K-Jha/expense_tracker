import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/expense.dart';

class ExpenseSearchDelegate extends SearchDelegate<Expense?> {
  final List<Expense> expenses;

  ExpenseSearchDelegate(this.expenses);

  @override
  String get searchFieldLabel => 'Search expenses...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final lowerQuery = query.toLowerCase();
    final filtered = expenses.where((e) {
      return e.description.toLowerCase().contains(lowerQuery) ||
          e.category.name.toLowerCase().contains(lowerQuery) ||
          e.paymentMethod.displayName.toLowerCase().contains(lowerQuery) ||
          e.amount.toStringAsFixed(2).contains(lowerQuery);
    }).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Text('No matching expenses', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final expense = filtered[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: expense.category.color.withValues(alpha: 0.2),
            child: Icon(expense.category.icon, color: expense.category.color),
          ),
          title: Text(expense.description),
          subtitle: Text(
            '${expense.category.name} • ${DateFormat('MMM d, yyyy').format(expense.date)}',
          ),
          trailing: Text(
            '\u20B9${expense.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () => close(context, expense),
        );
      },
    );
  }
}
