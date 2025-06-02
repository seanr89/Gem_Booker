import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/location_model.dart';
import '../models/models.dart'; // Import go_router

class LocationsScreen extends StatelessWidget {
  // Can be StatelessWidget if locations are passed in
  final List<LocationItem> locations;

  const LocationsScreen({super.key, required this.locations});

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Locations'),
        ),
        body: const Center(child: Text('No locations found.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locations'),
      ),
      body: ListView.builder(
        itemCount: locations.length,
        itemBuilder: (BuildContext context, int index) {
          final location = locations[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              title: Text(location.name),
              subtitle: Text(location.address),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('More options for ${location.name}')),
                  );
                },
              ),
              onTap: () {
                // Navigate to the single location screen
                context.go('/locations/${location.id}');
              },
            ),
          );
        },
      ),
    );
  }
}
