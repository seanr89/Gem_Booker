import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // For potential navigation from cards
import '../widgets/dashboard_card.dart'; // Import the new card widget

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Dummy data
  static const int totalLocations = 25;
  static const int activeUsers = 123;
  static const double systemHealth = 0.95; // 95%
  static const List<String> recentActivities = [
    'New location "Downtown Branch" added.',
    'User "Alice" updated her profile.',
    'Settings for "Notifications" changed.',
    'Location "Warehouse West" marked as inactive.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: _getCrossAxisCount(context), // Responsive columns
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: _getChildAspectRatio(
              context), // Adjust aspect ratio for better look
          children: <Widget>[
            DashboardCard(
              icon: Icons.location_city,
              title: 'Total Locations',
              value: totalLocations.toString(),
              iconColor: Colors.green,
              onTap: () {
                context.go('/locations'); // Navigate to locations screen
              },
            ),
            DashboardCard(
              icon: Icons.people_alt,
              title: 'Active Users',
              value: activeUsers.toString(),
              iconColor: Colors.orange,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User management coming soon!')),
                );
              },
            ),
            // A card showing a percentage with a progress bar
            Card(
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.health_and_safety,
                        size: 40.0, color: Colors.redAccent),
                    const SizedBox(height: 10.0),
                    Text(
                      'System Health',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      '${(systemHealth * 100).toStringAsFixed(0)}%',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 10.0),
                    LinearProgressIndicator(
                      value: systemHealth,
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.redAccent),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
            ),

            // Recent Activities Card (using ComplexDashboardCard)
            // For this to fit well, you might need to adjust aspect ratio or use a different grid item size
            // Or make this card span multiple columns if using GridView.custom
            ComplexDashboardCard(
              title: 'Recent Activities',
              titleIcon: Icons.history,
              child: ListView.builder(
                itemCount: recentActivities.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.circle,
                            size: 8, color: Colors.blueGrey),
                        const SizedBox(width: 8.0),
                        Expanded(
                            child: Text(recentActivities[index],
                                style: Theme.of(context).textTheme.bodySmall)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to make the grid responsive
  int _getCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) {
      return 4; // Large screens
    } else if (screenWidth > 800) {
      return 3; // Medium screens
    } else if (screenWidth > 500) {
      return 2; // Small screens / tablets portrait
    }
    return 1; // Mobile portrait (might want taller cards if 1)
  }

  // Adjust aspect ratio based on cross axis count
  double _getChildAspectRatio(BuildContext context) {
    int crossAxisCount = _getCrossAxisCount(context);
    if (crossAxisCount == 1) {
      return 2.0; // Taller cards if only one column
    } else if (crossAxisCount == 2) {
      return 1.2; // Slightly taller than wide
    }
    return 1.0; // Square-ish for more columns
  }
}
