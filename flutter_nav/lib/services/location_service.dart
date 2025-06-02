import 'dart:math';
import 'package:table_calendar/table_calendar.dart';
import 'api_service.dart'; // Your generic API service
// If needed directly
import '../models/location_model.dart'; // Import LocationItem model

class LocationService {
  final ApiService _apiService;

  LocationService(this._apiService);

  Future<List<LocationItem>> getAllLocations() async {
    try {
      final List<dynamic> responseData = await _apiService.get('locations');
      // Assuming responseData is a List of Map<String, dynamic>
      return responseData
          .map((json) => LocationItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      // Log error or handle specific API errors
      print('LocationService Error - getAllLocations: ${e.message}');
      rethrow; // Or return empty list / throw custom service exception
    } catch (e) {
      print('LocationService Unexpected Error - getAllLocations: $e');
      throw Exception('Failed to load locations');
    }
  }

  Future<LocationItem> getLocationById(String id) async {
    try {
      final dynamic responseData = await _apiService.get('locations/$id');
      // Assuming responseData is a Map<String, dynamic>
      return LocationItem.fromJson(responseData as Map<String, dynamic>);
    } on ApiException catch (e) {
      print('LocationService Error - getLocationById ($id): ${e.message}');
      rethrow;
    } catch (e) {
      print('LocationService Unexpected Error - getLocationById ($id): $e');
      throw Exception('Failed to load location with ID $id');
    }
  }

  // Example: If you need to fetch desk availability for a specific location and date
  // This is just a placeholder for how you might structure it.
  Future<Map<DateTime, List<String>>> getLocationDeskAvailability(
      String locationId, DateTime date) async {
    // API endpoint might be like: /locations/{locationId}/availability?date=YYYY-MM-DD
    // For now, we'll return dummy data or an empty map from the LocationItem itself
    // This is because the initial LocationItem.fromJson might not populate it fully.
    // In a real app, you'd make an API call here.
    print("Fetching availability for $locationId on $date (Simulated)");
    await Future.delayed(
        const Duration(milliseconds: 300)); // Simulate API call

    // Simulate some availability - in reality, this would be from an API response
    final Random random = Random();
    final List<String> deskIds = List.generate(
        random.nextInt(5) + 2, (i) => 'desk_sim_${locationId}_$i');
    Map<DateTime, List<String>> availability = {};
    availability[normalizeDate(date)] = deskIds;
    return availability;
  }
}
