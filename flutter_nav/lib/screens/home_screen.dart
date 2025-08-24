import 'dart:async'; // For Timer
import 'package:flutter/material.dart';
import 'package:flutter_nav/services/azure_api_service.dart';
import 'package:go_router/go_router.dart';
// To access ApiService if provided globally
import '../widgets/dashboard_card.dart';
import '../services/api_service.dart'; // Import ApiService

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Dummy data (can remain static or be part of state if it changes)
  static const int totalLocations = 25;
  static const int activeUsers = 123;
  static const double systemHealthValue = 0.95; // 95%
  static const List<String> recentActivities = [
    'New location "Downtown Branch" added.',
    'User "Alice" updated her profile.',
    'Settings for "Notifications" changed.',
    'Location "Warehouse West" marked as inactive.',
  ];

  ApiStatus _apiStatus = ApiStatus.unknown;
  Timer? _apiStatusTimer;
  late ApiService _apiService; // To be initialized
  late AzureApiService _azureApiService; // To be initialized

  // Refresh interval for API status
  static const Duration _refreshInterval = Duration(seconds: 60);

  @override
  void initState() {
    super.initState();
    // It's better to get ApiService via Provider if it's already set up that way
    // For this example, assuming we might instantiate it or get it.
    // If not using Provider for ApiService, you'd instantiate it here:
    _apiService = ApiService(
        baseUrl:
            'https://seatapi.kindmushroom-fdc7faf5.northeurope.azurecontainerapps.io');
    // If using Provider and ApiService is provided higher up:
    //_apiService = Provider.of<ApiService>(context, listen: false);
    _azureApiService = AzureApiService();

    _fetchApiStatus(); // Initial fetch
    _apiStatusTimer = Timer.periodic(_refreshInterval, (timer) {
      _fetchApiStatus();
    });
  }

  @override
  void dispose() {
    _apiStatusTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchApiStatus() async {
    if (!mounted) return;
    setState(() {
      _apiStatus = ApiStatus.checking;
    });

    try {
      bool isHealthy = await _azureApiService.checkHealth();
      if (!mounted) return;
      setState(() {
        _apiStatus = isHealthy ? ApiStatus.healthy : ApiStatus.unhealthy;
      });
    } catch (e) {
      if (!mounted) return;
      print("Error fetching API status: $e");
      setState(() {
        _apiStatus =
            ApiStatus.unhealthy; // Or unknown, depending on error handling
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: _getCrossAxisCount(context),
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: _getChildAspectRatio(context),
          children: <Widget>[
            DashboardCard(
              icon: Icons.location_city,
              title: 'Total Locations',
              value: totalLocations.toString(),
              azureApiService: _azureApiService,
              iconColor: Colors.green,
              apiStatus: _apiStatus, // Pass the status here
              onTap: () {
                context.go('/locations');
              },
            ),
            DashboardCard(
              icon: Icons.people_alt,
              title: 'Active Users',
              value: activeUsers.toString(),
              azureApiService: _azureApiService,
              iconColor: Colors.orange,
              // You could add another status check for a different service here
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User management coming soon!')),
                );
              },
            ),
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

  int _getCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 4;
    if (screenWidth > 800) return 3;
    if (screenWidth > 500) return 2;
    return 1;
  }

  double _getChildAspectRatio(BuildContext context) {
    int crossAxisCount = _getCrossAxisCount(context);
    if (crossAxisCount == 1) return 2.0;
    if (crossAxisCount == 2) return 1.2;
    return 1.0;
  }
}
