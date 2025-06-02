import 'package:flutter/material.dart';

enum ApiStatus { unknown, healthy, unhealthy, checking }

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;
  final VoidCallback? onTap;
  final ApiStatus? apiStatus; // New parameter for API status

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.iconColor = Colors.blue,
    this.onTap,
    this.apiStatus, // Initialize
  });

  Widget _buildStatusBadge() {
    Color badgeColor;
    Widget? child;

    switch (apiStatus) {
      case ApiStatus.healthy:
        badgeColor = Colors.green;
        break;
      case ApiStatus.unhealthy:
        badgeColor = Colors.red;
        break;
      case ApiStatus.checking:
        badgeColor = Colors.orange;
        child = const SizedBox(
            width: 8,
            height: 8,
            child: CircularProgressIndicator(
                strokeWidth: 1.5, color: Colors.white));
        break;
      case ApiStatus.unknown:
      default:
        badgeColor = Colors.grey;
        break;
    }

    return Container(
      width: 22.0,
      height: 22.0,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.5),
            blurRadius: 3.0,
            spreadRadius: 1.0,
          )
        ],
      ),
      child: child != null ? Center(child: child) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 40.0, color: iconColor),
                  if (apiStatus != null)
                    _buildStatusBadge(), // Display badge if status is provided
                ],
              ),
              const SizedBox(height: 10.0),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 5.0),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ComplexDashboardCard remains the same for now
class ComplexDashboardCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? titleIcon;
  final Color titleIconColor;

  const ComplexDashboardCard({
    super.key,
    required this.title,
    required this.child,
    this.titleIcon,
    this.titleIconColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                if (titleIcon != null) ...[
                  Icon(titleIcon, color: titleIconColor, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
