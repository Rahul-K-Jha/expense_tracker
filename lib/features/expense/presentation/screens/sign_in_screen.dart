import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../injection.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _authService = getIt<AuthService>();
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);

    final user = await _authService.signIn();

    if (mounted) {
      setState(() => _isLoading = false);

      if (user != null) {
        // Ask for spreadsheet ID and register sheets service
        await _promptSpreadsheetId();
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-in failed. Please try again.')),
        );
      }
    }
  }

  Future<void> _promptSpreadsheetId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('spreadsheet_id');

    if (savedId != null && savedId.isNotEmpty) {
      await _registerSheetsService(savedId);
      return;
    }

    if (!mounted) return;

    final controller = TextEditingController();
    final id = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Google Sheets Setup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your Google Spreadsheet ID to sync expenses.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Spreadsheet ID',
                hintText: 'From the URL: docs.google.com/spreadsheets/d/{ID}',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, ''),
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Connect'),
          ),
        ],
      ),
    );

    if (id != null && id.isNotEmpty) {
      await prefs.setString('spreadsheet_id', id);
      await _registerSheetsService(id);
    }
  }

  Future<void> _registerSheetsService(String spreadsheetId) async {
    final service = await _authService.createSheetsService(spreadsheetId);
    if (service != null) {
      registerGoogleSheetsService(service);
    }
  }

  void _skipSignIn() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Expense Tracker',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to sync your expenses with Google Sheets',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const Spacer(),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : OutlinedButton.icon(
                      onPressed: _handleSignIn,
                      icon: const Icon(Icons.login),
                      label: const Text('Sign in with Google'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _skipSignIn,
                child: const Text('Continue without sign-in (offline only)'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
