import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/expense.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_state.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spending Insights')),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoaded) {
            if (state.expenses.isEmpty) {
              return const Center(child: Text('No data for insights'));
            }
            return _buildInsights(state.expenses);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildInsights(List<Expense> expenses) {
    final now = DateTime.now();
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0);

    final thisWeek = _expensesInRange(expenses, thisWeekStart, now);
    final lastWeek = _expensesInRange(expenses, lastWeekStart, thisWeekStart);
    final thisMonth = _expensesInRange(expenses, thisMonthStart, now);
    final lastMonth = _expensesInRange(expenses, lastMonthStart, lastMonthEnd);

    final thisWeekTotal = _total(thisWeek);
    final lastWeekTotal = _total(lastWeek);
    final thisMonthTotal = _total(thisMonth);
    final lastMonthTotal = _total(lastMonth);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComparisonCard(
            'This Week vs Last Week',
            thisWeekTotal,
            lastWeekTotal,
          ),
          const SizedBox(height: 16),
          _buildComparisonCard(
            'This Month vs Last Month',
            thisMonthTotal,
            lastMonthTotal,
          ),
          const SizedBox(height: 24),
          _buildWeeklyTrendChart(expenses),
          const SizedBox(height: 24),
          _buildAnomalies(expenses),
          const SizedBox(height: 24),
          _buildWeeklyRecap(thisWeek),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(String title, double current, double previous) {
    final change = previous > 0 ? ((current - previous) / previous) * 100 : 0.0;
    final isUp = change > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      '\u20B9${current.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Previous', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      '\u20B9${previous.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            if (previous > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    isUp ? Icons.trending_up : Icons.trending_down,
                    color: isUp ? Colors.red : Colors.green,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${change.abs().toStringAsFixed(1)}% ${isUp ? 'more' : 'less'} than before',
                    style: TextStyle(
                      color: isUp ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyTrendChart(List<Expense> expenses) {
    final now = DateTime.now();
    final weeklyTotals = <double>[];
    final weekLabels = <String>[];

    for (int i = 7; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
      final weekEnd = weekStart.add(const Duration(days: 6));
      final total = _total(_expensesInRange(expenses, weekStart, weekEnd));
      weeklyTotals.add(total);
      weekLabels.add(DateFormat('d MMM').format(weekStart));
    }

    final maxY = weeklyTotals.isEmpty ? 100.0 : weeklyTotals.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Weekly Trend (8 weeks)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  maxY: maxY * 1.2,
                  minY: 0,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < weekLabels.length && idx % 2 == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(weekLabels[idx], style: const TextStyle(fontSize: 9)),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(weeklyTotals.length,
                          (i) => FlSpot(i.toDouble(), weeklyTotals[i])),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnomalies(List<Expense> expenses) {
    if (expenses.length < 5) return const SizedBox.shrink();

    final amounts = expenses.map((e) => e.amount).toList()..sort();
    final median = amounts[amounts.length ~/ 2];
    final threshold = median * 3;

    final anomalies = expenses.where((e) => e.amount > threshold).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    if (anomalies.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                const Text('Unusual Spending', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'These expenses are significantly higher than your median (\u20B9${median.toStringAsFixed(0)})',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            ...anomalies.take(5).map((e) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(e.category.icon, color: e.category.color),
                  title: Text(e.description),
                  subtitle: Text(DateFormat('MMM d').format(e.date)),
                  trailing: Text(
                    '\u20B9${e.amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyRecap(List<Expense> thisWeek) {
    if (thisWeek.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No expenses this week yet'),
        ),
      );
    }

    final total = _total(thisWeek);
    final avgPerDay = total / 7;
    final topCategory = _topCategory(thisWeek);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This Week Recap', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _recapRow('Total spent', '\u20B9${total.toStringAsFixed(2)}'),
            _recapRow('Daily average', '\u20B9${avgPerDay.toStringAsFixed(2)}'),
            _recapRow('Transactions', '${thisWeek.length}'),
            if (topCategory != null)
              _recapRow('Top category', topCategory),
          ],
        ),
      ),
    );
  }

  Widget _recapRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  List<Expense> _expensesInRange(List<Expense> expenses, DateTime start, DateTime end) {
    return expenses.where((e) => !e.date.isBefore(start) && !e.date.isAfter(end)).toList();
  }

  double _total(List<Expense> expenses) {
    return expenses.fold(0, (sum, e) => sum + e.amount);
  }

  String? _topCategory(List<Expense> expenses) {
    final map = <String, double>{};
    for (final e in expenses) {
      map[e.category.name] = (map[e.category.name] ?? 0) + e.amount;
    }
    if (map.isEmpty) return null;
    return map.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}
