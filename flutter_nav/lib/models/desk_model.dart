class Desk {
  final String id;
  final String name;
  final String type;

  Desk({
    required this.id,
    required this.name,
    required this.type,
  });

  factory Desk.fromJson(Map<String, dynamic> json) {
    return Desk(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }
}
