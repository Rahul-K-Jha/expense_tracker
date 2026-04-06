import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expense/presentation/screens/add_expense_screen.dart';
import 'package:expense_tracker/features/expense/presentation/screens/home_screen.dart';
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
    return BlocProvider(
      create: (_) => getIt<ExpenseBloc>(),
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/home':
              return MaterialPageRoute(builder: (_) => const HomeScreen());
            case '/add-expense':
              final expense = settings.arguments as Expense?;
              return MaterialPageRoute(
                builder: (_) => AddExpenseScreen(existingExpense: expense),
              );
            case '/sheet-selector':
              return MaterialPageRoute(builder: (_) => const SheetSelectorPage());
            default:
              return MaterialPageRoute(builder: (_) => const SplashScreen());
          }
        },
      ),
    );
  }
}
