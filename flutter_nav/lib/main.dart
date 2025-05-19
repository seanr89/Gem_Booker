import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'router.dart';
import 'services/settings_service.dart'; // Import SettingsService

void main() {
  // It's good practice to initialize services that might be needed early,
  // or ensure SharedPreferences is ready if your SettingsService constructor relies on it immediately.
  // However, SettingsService now handles its own async loading.
  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingsService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Example: Listen to dark mode setting to change theme
    final settings = Provider.of<SettingsService>(context);

    return MaterialApp.router(
      title: 'Flutter Web BNB',
      theme: ThemeData(
        brightness:
            settings.darkModeEnabled ? Brightness.dark : Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        // You can also adjust textTheme based on settings.fontSizeMultiplier here
        textTheme: Theme.of(context).textTheme.apply(
              fontSizeFactor: settings.fontSizeMultiplier,
            ),
      ),
      routerConfig: router,
    );
  }
}
