import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme_cubit.dart';
import '../../domain/entities/expense.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import '../widgets/expense_search_delegate.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          Builder(
            builder: (innerContext) {
              return IconButton(
                icon: const Icon(Icons.search),
                onPressed: () async {
                  final navigator = Navigator.of(innerContext);
                  final state = innerContext.read<ExpenseBloc>().state;
                  final expenses = state is ExpenseLoaded ? state.expenses : <Expense>[];
                  final selected = await showSearch(
                    context: innerContext,
                    delegate: ExpenseSearchDelegate(expenses),
                  );
                  if (selected != null) {
                    navigator.pushNamed('/add-expense', arguments: selected);
                  }
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () => Navigator.pushNamed(context, '/dashboard'),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              IconData icon;
              switch (mode) {
                case ThemeMode.light:
                  icon = Icons.light_mode;
                  break;
                case ThemeMode.dark:
                  icon = Icons.dark_mode;
                  break;
                case ThemeMode.system:
                  icon = Icons.brightness_auto;
                  break;
              }
              return IconButton(
                icon: Icon(icon),
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                tooltip: 'Theme: ${mode.name}',
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseInitial) {
            context.read<ExpenseBloc>().add(LoadExpenses());
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ExpenseError) {
            return _buildError(context, state.message);
          }
          if (state is ExpenseLoaded) {
            if (state.expenses.isEmpty) {
              return _buildEmpty();
            }
            return _buildExpenseList(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-expense'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.read<ExpenseBloc>().add(LoadExpenses()),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No expenses yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Tap + to add your first expense',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(BuildContext context, ExpenseLoaded state) {
    final grouped = _groupByDate(state.expenses);
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      children: [
        _buildSummaryHeader(state),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<ExpenseBloc>().add(LoadExpenses());
            },
            child: ListView.builder(
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final expenses = grouped[date]!;
                final dayTotal = expenses.fold<double>(0, (s, e) => s + e.amount);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateHeader(date, dayTotal),
                    ...expenses.map((e) => _buildExpenseTile(context, e)),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader(ExpenseLoaded state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(bottom: BorderSide(color: Colors.blue.shade100)),
      ),
      child: Column(
        children: [
          const Text('Total Expenses', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            '\u20B9${state.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          Text(
            '${state.expenses.length} transactions',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime date, double total) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    String label;
    if (date == today) {
      label = 'Today';
    } else if (date == yesterday) {
      label = 'Yesterday';
    } else {
      label = DateFormat('EEEE, MMM d').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
          ),
          Text(
            '\u20B9${total.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseTile(BuildContext context, Expense expense) {
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Expense'),
            content: const Text('Are you sure you want to delete this expense?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
            ],
          ),
        );
      },
      onDismissed: (_) {
        context.read<ExpenseBloc>().add(DeleteExpenseEvent(expense.id));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: expense.category.color.withValues(alpha: 0.2),
          child: Icon(expense.category.icon, color: expense.category.color),
        ),
        title: Text(expense.description),
        subtitle: Text(
          '${expense.category.name} • ${expense.paymentMethod.displayName}',
        ),
        trailing: Text(
          '\u20B9${expense.amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onTap: () => Navigator.pushNamed(context, '/add-expense', arguments: expense),
      ),
    );
  }

  Map<DateTime, List<Expense>> _groupByDate(List<Expense> expenses) {
    final map = <DateTime, List<Expense>>{};
    for (final expense in expenses) {
      final dateKey = DateTime(expense.date.year, expense.date.month, expense.date.day);
      map.putIfAbsent(dateKey, () => []).add(expense);
    }
    return map;
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('All Expenses'),
              onTap: () {
                context.read<ExpenseBloc>().add(LoadExpenses());
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('This Month'),
              onTap: () {
                final now = DateTime.now();
                final start = DateTime(now.year, now.month, 1);
                final end = DateTime(now.year, now.month + 1, 0);
                context.read<ExpenseBloc>().add(FilterByDateRange(start, end));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Last Month'),
              onTap: () {
                final now = DateTime.now();
                final start = DateTime(now.year, now.month - 1, 1);
                final end = DateTime(now.year, now.month, 0);
                context.read<ExpenseBloc>().add(FilterByDateRange(start, end));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
