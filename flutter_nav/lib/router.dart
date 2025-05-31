// lib/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'models/models.dart';
import 'screens/home_screen.dart';
import 'screens/locations_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/single_location_screen.dart';
import 'screens/admin_screen.dart'; // Import the new admin screen
import 'widgets/main_shell.dart';
import 'models/staff_member.dart'; // For LocationItem if it's still there
import 'dart:math';

// ... (existing _rootNavigatorKey, _shellNavigatorKey, _sampleLocations, findLocationById) ...
final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

List<LocationItem> _generateSampleLocations() {
  final Random random = Random();
  final List<LocationItem> locations = [];
  final today = normalizeDate(DateTime.now());

  for (int i = 0; i < 10; i++) {
    List<Desk> desksForThisLocation = [];
    for (int j = 0; j < random.nextInt(15) + 5; j++) {
      desksForThisLocation.add(Desk(
        id: 'desk_${i}_$j',
        name: 'Desk ${String.fromCharCode(65 + (j % 5))}${(j ~/ 5) + 1}',
        type: ['Standard', 'Standing', 'Hot Desk'][random.nextInt(3)],
      ));
    }
    Map<DateTime, List<String>> availability = {};
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      DateTime currentDate =
          normalizeDate(today.add(Duration(days: dayOffset)));
      List<String> availableDeskIdsToday = [];
      for (var desk in desksForThisLocation) {
        if (random.nextBool()) {
          availableDeskIdsToday.add(desk.id);
        }
      }
      availability[currentDate] = availableDeskIdsToday;
    }
    locations.add(LocationItem(
      id: 'loc_$i',
      name: 'Office Complex ${i + 1}',
      address: '${random.nextInt(500) + 100} Corporate Pkwy, City ${i % 3}',
      allDesks: desksForThisLocation,
      dailyDeskAvailability: availability,
    ));
  }
  return locations;
}

final List<LocationItem> _sampleLocations = _generateSampleLocations();

LocationItem? findLocationById(String id) {
  try {
    return _sampleLocations.firstWhere((location) => location.id == id);
  } catch (e) {
    return null;
  }
}

final GoRouter router = GoRouter(
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

    // Top-level route for the Admin page (covers the shell)
    GoRoute(
      path: '/admin',
      parentNavigatorKey:
          _rootNavigatorKey, // Use root navigator to display OVER the shell
      builder: (context, state) => const AdminScreen(),
    ),
    // You could also nest it under settings if preferred, but still use _rootNavigatorKey
    // to make it appear as a full screen:
    // GoRoute(
    //   path: '/settings/admin',
    //   parentNavigatorKey: _rootNavigatorKey,
    //   builder: (context, state) => const AdminScreen(),
    // ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.error}'),
    ),
  ),
  // Optional: Add a redirect for '/admin' if user is not authenticated as admin
  // redirect: (BuildContext context, GoRouterState state) {
  //   final bool loggedIn = ...; // check login status
  //   final bool isAdmin = ...; // check admin status
  //   final bool goingToAdmin = state.matchedLocation == '/admin';
  //
  //   if (!loggedIn && goingToAdmin) return '/login'; // or wherever your login is
  //   if (loggedIn && !isAdmin && goingToAdmin) return '/'; // redirect non-admins away
  //   return null; // no redirect
  // },
);
