// =======================================================================
// FILE: /lib/models/building_model.dart
// =======================================================================

/// Represents the data structure for a building.
class Building {
  final String id;
  final String name;
  final String location;

  Building({
    required this.id,
    required this.name,
    required this.location,
  });

  /// Creates a Building instance from a JSON map.
  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
    );
  }
}

/// Represents the data needed to create a new building.
class CreateBuildingDto {
  final String name;
  final String location;
  final int seats;

  CreateBuildingDto({
    required this.name,
    required this.location,
    required this.seats,
  });

  /// Converts the DTO to a JSON map for the API request body.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'seats': seats,
    };
  }
}
