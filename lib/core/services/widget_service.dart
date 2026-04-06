import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WidgetService {
  static const _appGroupId = 'com.example.expense_tracker';
  static const _widgetName = 'ExpenseSummaryWidget';

  Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  Future<void> updateWidget({
    required double todayTotal,
    required double monthTotal,
    required int transactionCount,
    required double budgetRemaining,
  }) async {
    await HomeWidget.saveWidgetData<double>('today_total', todayTotal);
    await HomeWidget.saveWidgetData<double>('month_total', monthTotal);
    await HomeWidget.saveWidgetData<int>('transaction_count', transactionCount);
    await HomeWidget.saveWidgetData<double>('budget_remaining', budgetRemaining);

    await HomeWidget.updateWidget(
      name: _widgetName,
      androidName: _widgetName,
    );

    // Also persist for quick access
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('widget_today_total', todayTotal);
    await prefs.setDouble('widget_month_total', monthTotal);
  }
}
