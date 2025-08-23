// =======================================================================
// FILE: /lib/services/api_service.dart
// =======================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_exception.dart';
import '../models/building_model.dart';
import '../models/seat_model.dart';
import '../models/booking_model.dart';

/// A central service for handling all API communications.
/// It manages the base URL, authentication headers, and core request logic.
class AzureApiService {
  final String _baseUrl =
      "https://seatapi.kindmushroom-fdc7faf5.northeurope.azurecontainerapps.io/api/v1";
  String? _token;

  /// Sets the JWT token for authenticating API requests.
  void setAuthToken(String token) {
    _token = token;
  }

  /// Clears the JWT token.
  void clearAuthToken() {
    _token = null;
  }

  /// Constructs the headers for an API request.
  /// Includes the Content-Type and Authorization headers if a token is present.
  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  /// Handles the response from an HTTP request, decoding JSON and checking for errors.
  dynamic _handleResponse(http.Response response) {
    final dynamic decodedBody = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    } else {
      // Attempt to get an error message from the response body
      final String errorMessage =
          decodedBody['message'] ?? 'An unknown error occurred.';
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  // -------------------------------------------------------------------
  // Building Endpoints
  // -------------------------------------------------------------------

  /// Fetches a list of all buildings.
  Future<List<Building>> getBuildings() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/building'),
      headers: _getHeaders(),
    );
    final List<dynamic> responseData = _handleResponse(response);
    return responseData.map((json) => Building.fromJson(json)).toList();
  }

  /// Creates a new building.
  Future<Building> createBuilding(CreateBuildingDto createBuildingDto) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/building'),
      headers: _getHeaders(),
      body: json.encode(createBuildingDto.toJson()),
    );
    final responseData = _handleResponse(response);
    return Building.fromJson(responseData);
  }

  /// Fetches all seats for a specific building.
  Future<List<Seat>> getSeatsForBuilding(String buildingId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/building/$buildingId/seats'),
      headers: _getHeaders(),
    );
    final List<dynamic> responseData = _handleResponse(response);
    return responseData.map((json) => Seat.fromJson(json)).toList();
  }

  // -------------------------------------------------------------------
  // Seat & Booking Endpoints
  // -------------------------------------------------------------------

  /// Fetches details for a specific seat by its ID.
  Future<Seat> getSeatById(String seatId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/seat/$seatId'),
      headers: _getHeaders(),
    );
    final responseData = _handleResponse(response);
    return Seat.fromJson(responseData);
  }

  /// Books a specific seat.
  /// Note: The API spec indicates a simple POST without a body.
  Future<Booking> bookSeat(String seatId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/seat/$seatId/book'),
      headers: _getHeaders(),
    );
    final responseData = _handleResponse(response);
    return Booking.fromJson(responseData);
  }

  /// Cancels a booking for a specific seat.
  Future<void> cancelBooking(String seatId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/seat/$seatId/book'),
      headers: _getHeaders(),
    );
    _handleResponse(response); // Throws ApiException on failure
  }

  // -------------------------------------------------------------------
  // User Endpoints
  // -------------------------------------------------------------------

  /// Fetches all bookings for the currently authenticated user.
  Future<List<Booking>> getUserBookings() async {
    if (_token == null) {
      throw ApiException("Authentication token is not set.");
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/user/bookings'),
      headers: _getHeaders(),
    );
    final List<dynamic> responseData = _handleResponse(response);
    return responseData.map((json) => Booking.fromJson(json)).toList();
  }
}
