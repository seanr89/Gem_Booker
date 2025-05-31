import 'dart:async';

import 'package:flutter/material.dart';
import '../models/staff_member.dart'; // Import the models
import 'dart:math'; // For random status changes

// Dummy data generation - In a real app, this would come from a service/API
List<StaffMember> _generateDummyStaff() {
  final Random random = Random();
  final List<String> names = [
    'Alice Wonderland',
    'Bob The Builder',
    'Charlie Brown',
    'Diana Prince',
    'Edward Scissorhands',
    'Fiona Apple',
    'George Jetson',
    'Harley Quinn'
  ];
  final List<String> roles = [
    'Developer',
    'Manager',
    'Support',
    'Designer',
    'QA'
  ];
  final List<String> avatarPlaceholders = [
    'https://i.pravatar.cc/150?img=1',
    'https://i.pravatar.cc/150?img=2',
    'https://i.pravatar.cc/150?img=3',
    'https://i.pravatar.cc/150?img=4',
    'https://i.pravatar.cc/150?img=5',
  ];

  return List.generate(8, (index) {
    String name = names[index % names.length];
    return StaffMember(
      id: 'staff_$index',
      name: name,
      role: roles[random.nextInt(roles.length)],
      email: '${name.toLowerCase().replaceAll(' ', '.')}@example.com',
      avatarUrl: avatarPlaceholders[random.nextInt(avatarPlaceholders.length)],
      status: StaffStatus.values[random.nextInt(StaffStatus.values.length)],
    );
  });
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late List<StaffMember> _staffMembers;
  Timer? _statusUpdateTimer;

  @override
  void initState() {
    super.initState();
    _staffMembers = _generateDummyStaff();
    // Simulate status updates periodically
    _statusUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateRandomStaffStatus();
    });
  }

  @override
  void dispose() {
    _statusUpdateTimer?.cancel();
    super.dispose();
  }

  void _updateRandomStaffStatus() {
    if (_staffMembers.isEmpty || !mounted) return;
    final Random random = Random();
    final int staffIndex = random.nextInt(_staffMembers.length);
    setState(() {
      _staffMembers[staffIndex].status =
          StaffStatus.values[random.nextInt(StaffStatus.values.length)];
    });
  }

  Widget _buildStatusIndicator(StaffStatus status) {
    Color color;
    String text;
    IconData iconData;

    switch (status) {
      case StaffStatus.online:
        color = Colors.green;
        text = 'Online';
        iconData = Icons.check_circle;
        break;
      case StaffStatus.offline:
        color = Colors.grey;
        text = 'Offline';
        iconData = Icons.cancel;
        break;
      case StaffStatus.busy:
        color = Colors.red;
        text = 'Busy';
        iconData = Icons.do_not_disturb_on;
        break;
      case StaffStatus.onBreak:
        color = Colors.orange;
        text = 'On Break';
        iconData = Icons.free_breakfast;
        break;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconData, color: color, size: 16),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Staff Overview'),
        // If this screen is pushed onto the root navigator, it will have a back button.
        // If it's part of the shell, the shell's structure will dictate navigation.
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _staffMembers.length,
        itemBuilder: (context, index) {
          final staff = _staffMembers[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: staff.avatarUrl != null
                    ? NetworkImage(staff.avatarUrl!)
                    : null,
                child: staff.avatarUrl == null
                    ? Text(staff.name.substring(0, 1).toUpperCase())
                    : null,
                backgroundColor: Colors.grey[300],
              ),
              title: Text(staff.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(staff.role),
                  Text(staff.email,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              trailing: _buildStatusIndicator(staff.status),
              onTap: () {
                // Potential: Navigate to a staff detail page or show more options
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tapped on ${staff.name}')),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Example: Add new staff or refresh list from API
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Action button tapped!')),
          );
        },
        tooltip: 'Admin Action',
        child: const Icon(Icons.add),
      ),
    );
  }
}
