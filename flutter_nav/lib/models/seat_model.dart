// =======================================================================
// FILE: /lib/models/seat_model.dart
// =======================================================================

/// Represents the data structure for a seat.
class Seat {
  final String id;
  final String seatNumber;
  final bool isAvailable;

  Seat({
    required this.id,
    required this.seatNumber,
    required this.isAvailable,
  });

  /// Creates a Seat instance from a JSON map.
  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id'] ?? '',
      seatNumber: json['seatNumber'] ?? '',
      isAvailable: json['isAvailable'] ?? false,
    );
  }
}
