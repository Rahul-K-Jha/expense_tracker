// TODO: Add Firebase Crashlytics

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/core/bloc/app_bloc_observer.dart';
import 'package:expense_tracker/injection.dart' as di;

void main() {
  runZonedGuarded(
    () async {
      // Initialize Flutter
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize dependency injection
      await di.configureDependencies();

      // Set the Bloc Observer to observe bloc state changes
      Bloc.observer = AppBlocObserver();

      // Run the app!
      runApp(const App());
    },
    (error, stackTrace) {
      log('Error outside of Flutter framework: $error');
      log('Stack trace: $stackTrace');
      // Example of sending to Crashlytics (if you have it set up):
      // FirebaseCrashlytics.instance.recordError(error, stackTrace);
    },
  );
}
