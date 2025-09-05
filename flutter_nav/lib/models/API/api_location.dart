/// Represents the data structure for a building.
class APILocation {
  final String id;
  final String name;
  final String location;

  APILocation({
    required this.id,
    required this.name,
    required this.location,
  });

  /// Creates a Building instance from a JSON map.
  factory APILocation.fromJson(Map<String, dynamic> json) {
    return APILocation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
    );
  }
}
