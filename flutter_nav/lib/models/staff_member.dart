enum StaffStatus {
  online,
  offline,
  busy,
  onBreak,
}

class StaffMember {
  final String id;
  final String name;
  final String role;
  final String email;
  final String? avatarUrl; // Optional
  StaffStatus status; // Mutable status

  StaffMember({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    this.avatarUrl,
    required this.status,
  });
}
