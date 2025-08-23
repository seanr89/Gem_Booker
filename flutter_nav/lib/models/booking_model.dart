// =======================================================================
// FILE: /lib/models/booking_model.dart
// =======================================================================

/// Represents the data structure for a booking.
class Booking {
  final String id;
  final String seatId;
  final String userId;
  final String bookingTime; // Using String for simplicity, can be DateTime

  Booking({
    required this.id,
    required this.seatId,
    required this.userId,
    required this.bookingTime,
  });

  /// Creates a Booking instance from a JSON map.
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      seatId: json['seatId'] ?? '',
      userId: json['userId'] ?? '',
      bookingTime: json['bookingTime'] ?? '',
    );
  }
}
