// =======================================================================
// FILE: /lib/services/api_exception.dart
// =======================================================================

/// Custom exception class for API-related errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    return 'ApiException: $message (Status code: $statusCode)';
  }
}
