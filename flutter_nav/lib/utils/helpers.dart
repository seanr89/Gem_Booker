import 'dart:math';

import 'package:flutter_nav/models/desk_model.dart';
import 'package:flutter_nav/models/location_model.dart';
import 'package:table_calendar/table_calendar.dart';

class Helpers {
  // Private constructor to prevent instantiation
  Helpers._();

  static List<LocationItem> generateSampleLocations() {
    final Random random = Random();
    final List<LocationItem> locations = [];
    final today = normalizeDate(DateTime.now());

    for (int i = 0; i < 5; i++) {
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

  /// Returns `date` in UTC format, without its time part.
  // static DateTime normalizeDate(DateTime date) {
  //   return DateTime.utc(date.year, date.month, date.day);
  // }
}
