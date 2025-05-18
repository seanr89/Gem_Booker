import 'dart:async';
import 'dart:convert';
import 'dart:io'; // For HttpException
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl;

  // Constructor to set the base URL for the API
  ApiService({required String baseUrl}) : _baseUrl = baseUrl;

  // --- Private Helper Methods ---

  // Helper to build the full URL
  Uri _buildUri(String endpoint, Map<String, String>? queryParameters) {
    final uri = Uri.parse('$_baseUrl/$endpoint');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: queryParameters);
    }
    return uri;
  }

  // Helper to handle common response logic and error throwing
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      if (responseBody.isEmpty) {
        return null; // Or an empty map/list if appropriate for your API
      }
      try {
        return jsonDecode(responseBody);
      } catch (e) {
        // If response is not JSON but still successful (e.g., plain text)
        // You might want to return responseBody directly or handle differently
        print('Error decoding JSON: $e');
        throw ApiException(
          message: 'Failed to parse JSON response.',
          statusCode: statusCode,
          responseBody: responseBody,
        );
      }
    } else if (statusCode == 401) {
      // Specific handling for unauthorized, e.g., trigger logout
      print('API Error: Unauthorized (401)');
      throw ApiException(
        message: 'Unauthorized. Please log in again.',
        statusCode: statusCode,
        responseBody: responseBody,
      );
    } else if (statusCode == 403) {
      print('API Error: Forbidden (403)');
      throw ApiException(
        message: 'Access denied.',
        statusCode: statusCode,
        responseBody: responseBody,
      );
    } else if (statusCode >= 400 && statusCode < 500) {
      print('API Error: Client Error ($statusCode)');
      // Try to parse error message from response body if it's JSON
      String errorMessage = 'Client error occurred.';
      try {
        final decodedBody = jsonDecode(responseBody);
        if (decodedBody is Map && decodedBody.containsKey('message')) {
          errorMessage = decodedBody['message'];
        } else if (decodedBody is Map && decodedBody.containsKey('error')) {
          errorMessage = decodedBody['error'];
        }
      } catch (_) {
        /* Ignore if not JSON or doesn't have expected error structure */
      }
      throw ApiException(
        message: errorMessage,
        statusCode: statusCode,
        responseBody: responseBody,
      );
    } else {
      print('API Error: Server Error ($statusCode)');
      throw ApiException(
        message: 'Server error occurred. Please try again later.',
        statusCode: statusCode,
        responseBody: responseBody,
      );
    }
  }

  // --- Public API Methods ---

  /// Performs a GET request.
  ///
  /// [endpoint]: The API endpoint (e.g., 'users', 'products/123').
  /// [queryParameters]: Optional map of query parameters.
  /// [headers]: Optional custom headers.
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    print('GET: $uri');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (headers != null) ...headers, // Merge custom headers
          // Add Authorization header if you have a token
          // 'Authorization': 'Bearer YOUR_TOKEN_HERE',
        },
      ).timeout(const Duration(seconds: 30)); // Add a timeout

      return _handleResponse(response);
    } on SocketException {
      print('Network Error: No Internet connection or host unreachable.');
      throw ApiException(
          message: 'Network error. Please check your connection.');
    } on TimeoutException {
      print('Network Error: Request timed out.');
      throw ApiException(message: 'The request timed out. Please try again.');
    } catch (e) {
      print('Generic GET Error: $e');
      if (e is ApiException)
        rethrow; // Re-throw if it's already our custom exception
      throw ApiException(
          message: 'An unexpected error occurred during GET request.');
    }
  }

  /// Performs a POST request.
  ///
  /// [endpoint]: The API endpoint.
  /// [body]: The request body, typically a Map<String, dynamic> which will be JSON encoded.
  /// [headers]: Optional custom headers.
  Future<dynamic> post(
    String endpoint, {
    required dynamic body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(
        endpoint, null); // POST usually doesn't use query params in URI
    print('POST: $uri, Body: $body');

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              if (headers != null) ...headers,
              // 'Authorization': 'Bearer YOUR_TOKEN_HERE',
            },
            body: jsonEncode(body), // Encode the body to JSON
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      print('Network Error: No Internet connection or host unreachable.');
      throw ApiException(
          message: 'Network error. Please check your connection.');
    } on TimeoutException {
      print('Network Error: Request timed out.');
      throw ApiException(message: 'The request timed out. Please try again.');
    } catch (e) {
      print('Generic POST Error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(
          message: 'An unexpected error occurred during POST request.');
    }
  }

  // You can add other methods like put, delete, patch similarly
  // Example:
  /*
  Future<dynamic> put(
    String endpoint, {
    required dynamic body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint, null);
    print('PUT: $uri, Body: $body');
    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (headers != null) ...headers,
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'Network error. Please check your connection.');
    } on TimeoutException {
      throw ApiException(message: 'The request timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'An unexpected error occurred during PUT request.');
    }
  }
  */
}

/// Custom Exception class for API related errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody; // For debugging or more detailed error info

  ApiException({required this.message, this.statusCode, this.responseBody});

  @override
  String toString() {
    String result = 'ApiException: $message';
    if (statusCode != null) {
      result += ' (Status Code: $statusCode)';
    }
    if (responseBody != null && responseBody!.isNotEmpty) {
      // Only show a snippet if it's too long
      final snippet = responseBody!.length > 100
          ? '${responseBody!.substring(0, 100)}...'
          : responseBody;
      result += '\nResponse Body: $snippet';
    }
    return result;
  }
}
