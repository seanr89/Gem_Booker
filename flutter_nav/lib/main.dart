import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' hide Provider; // Import provider
import 'router.dart';
import 'services/api_service.dart';
import 'services/settings_service.dart'; // Import SettingsService

void main() {
  // It's good practice to initialize services that might be needed early,
  // or ensure SharedPreferences is ready if your SettingsService constructor relies on it immediately.
  // However, SettingsService now handles its own async loading.
  // runApp(
  //   ChangeNotifierProvider(
  //     create: (context) => SettingsService(),
  //     child: const MyApp(),
  //   ),
  // );
  runApp(const ProviderScope(child: MyApp()));
  // runApp(
  //   MultiProvider(
  //     // Use MultiProvider if you have more than one
  //     providers: [
  //       ChangeNotifierProvider(create: (context) => SettingsService()),
  //       Provider(
  //           create: (context) => ApiService(
  //               baseUrl:
  //                   'https://jsonplaceholder.typicode.com')), // Provide ApiService
  //     ],
  //     child: const MyApp(),
  //   ),
  // );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Example: Listen to dark mode setting to change theme
    //final settings = Provider.of<SettingsService>(context);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Seat Booker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
