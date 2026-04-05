import 'package:expense_tracker/features/sheet_selector/presentation/screens/sheet_selector.dart';
import 'package:expense_tracker/features/expense/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          return MaterialPageRoute(builder: (context) => const SheetSelectorPage());
        }
        // Always show SplashScreen for any other or unknown route
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      },
    );
  }
}
