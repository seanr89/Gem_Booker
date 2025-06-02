import 'package:table_calendar/table_calendar.dart';

import 'desk_model.dart'; // Import Desk model

// Helper to normalize DateTime to midnight for use as Map keys
// DateTime normalizeDate(DateTime dateTime) {
//   return DateTime(dateTime.year, dateTime.month, dateTime.day);
// }

class LocationItem {
  final String id;
  final String name;
  final String address;
  final List<Desk> allDesks;
  // For simplicity, API might return availability differently.
  // We'll assume API returns allDesks, and availability might be another endpoint or derived.
  // For now, let's keep dailyDeskAvailability for the UI but it won't be directly from /locations API.
  // Or, the API for /locations/{id} might return this detailed availability.
  final Map<DateTime, List<String>> dailyDeskAvailability;

  LocationItem({
    required this.id,
    required this.name,
    required this.address,
    required this.allDesks,
    required this.dailyDeskAvailability, // This might be populated by a separate call or logic
  });

  factory LocationItem.fromJson(Map<String, dynamic> json) {
    var desksFromJson = json['allDesks'] as List?;
    List<Desk> desksList = desksFromJson != null
        ? desksFromJson
            .map((i) => Desk.fromJson(i as Map<String, dynamic>))
            .toList()
        : [];

    // Placeholder for dailyDeskAvailability - API for /locations/{id} might provide this
    // Or you might have another endpoint like /locations/{id}/availability
    // For this example, we'll initialize it as empty and it can be filled later.
    Map<DateTime, List<String>> availability = {};
    if (json['dailyDeskAvailability'] != null &&
        json['dailyDeskAvailability'] is Map) {
      // Assuming API returns dates as "YYYY-MM-DD" strings and list of desk IDs
      (json['dailyDeskAvailability'] as Map<String, dynamic>)
          .forEach((dateString, deskIds) {
        try {
          final date = normalizeDate(DateTime.parse(dateString));
          if (deskIds is List) {
            availability[date] = List<String>.from(deskIds);
          }
        } catch (e) {
          print("Error parsing date from availability: $dateString");
        }
      });
    }

    return LocationItem(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      allDesks: desksList,
      dailyDeskAvailability:
          availability, // Keep this, may be populated differently
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'allDesks': allDesks.map((desk) => desk.toJson()).toList(),
      'dailyDeskAvailability': dailyDeskAvailability.map((date, ids) =>
          MapEntry(date.toIso8601String().substring(0, 10), ids)),
    };
  }
}
