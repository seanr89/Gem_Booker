// lib/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_nav/screens/login_screen.dart';
import 'package:flutter_nav/screens/signup_screen.dart';
import 'package:flutter_nav/services/auth/auth_service.dart';
import 'package:flutter_nav/utils/helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'models/location_model.dart';
import 'screens/home_screen.dart';
import 'screens/locations_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/single_location_screen.dart';
import 'screens/admin_screen.dart'; // Import the new admin screen
import 'widgets/main_shell.dart';

// ... (existing _rootNavigatorKey, _shellNavigatorKey, _sampleLocations, findLocationById) ...
final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');
final GlobalKey<NavigatorState> _authNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'auth');

final List<LocationItem> _sampleLocations = Helpers.generateSampleLocations();

LocationItem? findLocationById(String id) {
  try {
    return _sampleLocations.firstWhere((location) => location.id == id);
  } catch (e) {
    return null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey, // Root navigator for the whole app
    routes: [
      // ShellRoute for main app navigation with BottomNavBar
      ShellRoute(
        navigatorKey:
            _shellNavigatorKey, // Navigator for content within the shell
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/locations',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) =>
                LocationsScreen(locations: _sampleLocations),
            routes: [
              GoRoute(
                path: ':locationId',
                parentNavigatorKey: _shellNavigatorKey,
                builder: (context, state) {
                  final locationId = state.pathParameters['locationId']!;
                  final location = findLocationById(locationId);
                  if (location == null) {
                    return const Scaffold(
                        body: Center(child: Text('Location not found')));
                  }
                  return SingleLocationScreen(location: location);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      ShellRoute(
          navigatorKey:
              _authNavigatorKey, // Navigator for content within the shell
          builder: (context, state, child) {
            return child;
          },
          routes: [
            GoRoute(
                path: '/login',
                parentNavigatorKey: _authNavigatorKey,
                builder: (context, state) => const LoginScreen()),
            GoRoute(
              path: '/signup',
              parentNavigatorKey: _authNavigatorKey,
              builder: (context, state) => const SignupScreen(),
            ),
          ]),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminScreen(),
      )
    ],
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        return '/';
      }

      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});
