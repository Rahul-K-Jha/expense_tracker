import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_cubit.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expense/presentation/screens/add_expense_screen.dart';
import 'package:expense_tracker/features/expense/presentation/screens/budget_screen.dart';
import 'package:expense_tracker/features/expense/presentation/screens/category_management_screen.dart';
import 'package:expense_tracker/features/expense/presentation/screens/dashboard_screen.dart';
import 'package:expense_tracker/features/expense/presentation/screens/goals_screen.dart';
import 'package:expense_tracker/features/expense/presentation/screens/home_screen.dart';
import 'package:expense_tracker/features/expense/presentation/screens/insights_screen.dart';
import 'package:expense_tracker/features/expense/presentation/screens/lock_screen.dart';
import 'package:expense_tracker/features/expense/presentation/screens/receipt_scanner_screen.dart';
import 'package:expense_tracker/features/expense/presentation/screens/recurring_expenses_screen.dart';
import 'package:expense_tracker/features/expense/presentation/screens/sign_in_screen.dart';
import 'package:expense_tracker/features/expense/presentation/screens/split_expense_screen.dart';
import 'package:expense_tracker/features/expense/presentation/screens/voice_input_screen.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/sheet_selector/presentation/screens/sheet_selector.dart';
import 'package:expense_tracker/features/expense/presentation/screens/splash_screen.dart';
import 'package:expense_tracker/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ExpenseBloc>()),
        BlocProvider(create: (_) => ThemeCubit()..loadTheme()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Expense Tracker',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/home':
                  return MaterialPageRoute(builder: (_) => const HomeScreen());
                case '/add-expense':
                  final expense = settings.arguments as Expense?;
                  return MaterialPageRoute(
                    builder: (_) => AddExpenseScreen(existingExpense: expense),
                  );
                case '/dashboard':
                  return MaterialPageRoute(builder: (_) => const DashboardScreen());
                case '/budgets':
                  return MaterialPageRoute(builder: (_) => const BudgetScreen());
                case '/categories':
                  return MaterialPageRoute(builder: (_) => const CategoryManagementScreen());
                case '/scan-receipt':
                  return MaterialPageRoute(builder: (_) => const ReceiptScannerScreen());
                case '/insights':
                  return MaterialPageRoute(builder: (_) => const InsightsScreen());
                case '/recurring':
                  return MaterialPageRoute(builder: (_) => const RecurringExpensesScreen());
                case '/sign-in':
                  return MaterialPageRoute(builder: (_) => const SignInScreen());
                case '/lock':
                  return MaterialPageRoute(builder: (_) => const LockScreen());
                case '/voice-input':
                  return MaterialPageRoute(builder: (_) => const VoiceInputScreen());
                case '/goals':
                  return MaterialPageRoute(builder: (_) => const GoalsScreen());
                case '/split':
                  return MaterialPageRoute(builder: (_) => const SplitExpenseScreen());
                case '/sheet-selector':
                  return MaterialPageRoute(builder: (_) => const SheetSelectorPage());
                default:
                  return MaterialPageRoute(builder: (_) => const SplashScreen());
              }
            },
          );
        },
      ),
    );
  }
}
