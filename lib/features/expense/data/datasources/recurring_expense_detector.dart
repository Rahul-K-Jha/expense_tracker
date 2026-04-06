import '../../domain/entities/expense.dart';

class RecurringPattern {
  final String description;
  final double amount;
  final int frequency; // approximate days between occurrences
  final List<Expense> matchingExpenses;

  RecurringPattern({
    required this.description,
    required this.amount,
    required this.frequency,
    required this.matchingExpenses,
  });

  String get frequencyLabel {
    if (frequency <= 8) return 'Weekly';
    if (frequency <= 16) return 'Bi-weekly';
    if (frequency <= 35) return 'Monthly';
    if (frequency <= 95) return 'Quarterly';
    return 'Yearly';
  }

  double get monthlyEstimate {
    return (30 / frequency) * amount;
  }
}

class RecurringExpenseDetector {
  /// Detect recurring expense patterns from a list of expenses.
  /// Groups expenses by similar description and amount, then checks
  /// if they occur at regular intervals.
  static List<RecurringPattern> detect(List<Expense> expenses) {
    if (expenses.length < 3) return [];

    final patterns = <RecurringPattern>[];

    // Group by normalized description
    final groups = <String, List<Expense>>{};
    for (final expense in expenses) {
      final key = _normalizeDescription(expense.description);
      groups.putIfAbsent(key, () => []).add(expense);
    }

    for (final entry in groups.entries) {
      final group = entry.value;
      if (group.length < 2) continue;

      // Check if amounts are similar (within 10%)
      final amounts = group.map((e) => e.amount).toList();
      final avgAmount = amounts.reduce((a, b) => a + b) / amounts.length;
      final allSimilar = amounts.every(
        (a) => (a - avgAmount).abs() / avgAmount < 0.1,
      );

      if (!allSimilar) continue;

      // Check for regular intervals
      group.sort((a, b) => a.date.compareTo(b.date));
      final intervals = <int>[];
      for (int i = 1; i < group.length; i++) {
        intervals.add(group[i].date.difference(group[i - 1].date).inDays);
      }

      if (intervals.isEmpty) continue;

      final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;
      final isRegular = intervals.every(
        (i) => (i - avgInterval).abs() < avgInterval * 0.3,
      );

      if (isRegular && avgInterval > 5) {
        patterns.add(RecurringPattern(
          description: entry.key,
          amount: avgAmount,
          frequency: avgInterval.round(),
          matchingExpenses: group,
        ));
      }
    }

    patterns.sort((a, b) => b.monthlyEstimate.compareTo(a.monthlyEstimate));
    return patterns;
  }

  static String _normalizeDescription(String desc) {
    return desc.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
