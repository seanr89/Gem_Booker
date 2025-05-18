// lib/screens/locations_screen.dart (or a new models.dart)

// Keep LocationItem here or move both to a models.dart
class LocationItem {
  final String id;
  final String name;
  final String address;
  final List<Desk> allDesks; // All desks belonging to this location
  final Map<DateTime, List<String>>
      dailyDeskAvailability; // Key: Date (normalized to midnight), Value: List of available desk IDs

  LocationItem({
    required this.id,
    required this.name,
    required this.address,
    required this.allDesks,
    required this.dailyDeskAvailability,
  });
}

class Desk {
  final String id;
  final String name; // e.g., "Desk A1", "Window Seat 3"
  final String type; // e.g., "Standard", "Standing", "Hot Desk"

  Desk({required this.id, required this.name, required this.type});
}

// Helper to normalize DateTime to midnight for use as Map keys
// DateTime normalizeDate(DateTime dateTime) {
//   return DateTime(dateTime.year, dateTime.month, dateTime.day);
// }
