// lib/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'models/models.dart';
import 'screens/home_screen.dart';
import 'screens/locations_screen.dart'; // Make sure Desk and normalizeDate are accessible
import 'screens/settings_screen.dart';
import 'screens/single_location_screen.dart';
import 'widgets/main_shell.dart';
import 'dart:math'; // For random data

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// --- Updated Sample Data Generation ---
List<LocationItem> _generateSampleLocations() {
  final Random random = Random();
  final List<LocationItem> locations = [];
  final today = normalizeDate(DateTime.now());

  for (int i = 0; i < 10; i++) {
    // Create 10 locations
    List<Desk> desksForThisLocation = [];
    for (int j = 0; j < random.nextInt(15) + 5; j++) {
      // 5-19 desks per location
      desksForThisLocation.add(Desk(
        id: 'desk_${i}_$j',
        name:
            'Desk ${String.fromCharCode(65 + (j % 5))}${(j ~/ 5) + 1}', // A1, B1, ..., A2, ...
        type: ['Standard', 'Standing', 'Hot Desk'][random.nextInt(3)],
      ));
    }

    Map<DateTime, List<String>> availability = {};
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      // Availability for next 7 days
      DateTime currentDate =
          normalizeDate(today.add(Duration(days: dayOffset)));
      List<String> availableDeskIdsToday = [];
      for (var desk in desksForThisLocation) {
        if (random.nextBool()) {
          // Randomly make a desk available
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

// Helper to find a location by ID
LocationItem? findLocationById(String id) {
  try {
    return _sampleLocations.firstWhere((location) => location.id == id);
  } catch (e) {
    return null;
  }
}
// --- End of Updated Sample Data ---

final GoRouter router = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
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
                final location = findLocationById(locationId); // Use helper
                if (location == null) {
                  // Ideally, have a dedicated error screen or handle in SingleLocationScreen
                  return const Scaffold(
                      body: Center(child: Text('Location not found')));
                }
                return SingleLocationScreen(
                    location: location); // Pass the whole LocationItem
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
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.error}'),
    ),
  ),
);
