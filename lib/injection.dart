import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

class DemoService {
  String getMessage() => 'Hello from DemoService!';
}

Future<void> configureDependencies() async {
  // Register DemoService as a singleton
  getIt.registerLazySingleton<DemoService>(() => DemoService());
  // Register your other services, repositories, blocs, etc. here
  // getIt.registerFactory<SomeBloc>(() => SomeBloc(getIt()));
}

// Example usage elsewhere in your app:
// final demoService = getIt<DemoService>();
// print(demoService.getMessage()); 