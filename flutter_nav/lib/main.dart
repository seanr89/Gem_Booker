import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_nav/services/auth/firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' hide Provider; // Import provider
import 'router.dart';
import 'services/api_service.dart';
import 'services/settings_service.dart'; // Import SettingsService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    await dotenv.load(fileName: "assets/.env");
  } else {
    print('Skipping file load');
    //print(const String.fromEnvironment('API_KEY', defaultValue: 'Unknown'));
  }
  // await dotenv.load(fileName: "assets/.env", mergeWith: Platform.environment);
  //await dotenv.load(fileName: "assets/.env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Example: Listen to dark mode setting to change theme
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
