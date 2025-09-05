// =======================================================================
// FILE: /lib/services/api_service.dart
// =======================================================================

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_nav/models/location_model.dart';
import 'package:http/http.dart' as http;
import 'api_exception.dart';
import '../models/seat_model.dart';
import '../models/booking_model.dart';

/// A central service for handling all API communications.
/// It manages the base URL, authentication headers, and core request logic.
class AzureApiService {
  final String _baseUrl =
      "https://seatapi.kindmushroom-fdc7faf5.northeurope.azurecontainerapps.io/";
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
  // HealthCheck Endpoints
  // -------------------------------------------------------------------
  Future<bool> checkHealth() async {
    final token = await getUserToken();
    setAuthToken(token!);

    final response = await http.get(
      Uri.parse('$_baseUrl/api/Home/HealthCheck'),
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkDbHealth() async {
    final token = await getUserToken();
    setAuthToken(token!);

    final response = await http.get(
      Uri.parse('$_baseUrl/api/Home/CheckDbConnection'),
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // -------------------------------------------------------------------
  // Locations Endpoints
  // -------------------------------------------------------------------

  /// get all location
  Future<List<LocationItem>> getLocations() async {
    print('Getting locations...');
    final token = await getUserToken();
    setAuthToken(token!);

    final response = await http.get(
      Uri.parse('$_baseUrl/api/Location/GetLocations'),
      headers: _getHeaders(),
    );
    final List<dynamic> responseData = _handleResponse(response);
    return responseData.map((json) => LocationItem.fromJson(json)).toList();
  }

  /// request a single location by Id
  Future<LocationItem> getLocationById(int id) async {
    print('Getting location with id: $id...');
    final token = await getUserToken();
    setAuthToken(token!);

    final response = await http.get(
      Uri.parse('$_baseUrl/api/Location/GetLocation/$id'),
      headers: _getHeaders(),
    );
    final dynamic responseData = _handleResponse(response);
    return responseData.map((json) => LocationItem.fromJson(json));
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

  Future<String?> getUserToken() async {
    final user = FirebaseAuth.instance.currentUser!;
    final idToken = await user.getIdToken();
    final token = idToken;
    return token;
  }
}
