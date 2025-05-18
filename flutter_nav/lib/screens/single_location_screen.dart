import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/models.dart';
import 'locations_screen.dart'; // For LocationItem, Desk, normalizeDate
// Assuming ApiService might be used later, but not directly in this dialog for now
// import '../services/api_service.dart';

class SingleLocationScreen extends StatefulWidget {
  final LocationItem location;

  const SingleLocationScreen({
    super.key,
    required this.location,
  });

  @override
  State<SingleLocationScreen> createState() => _SingleLocationScreenState();
}

class _SingleLocationScreenState extends State<SingleLocationScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  List<Desk> _availableDesksForSelectedDay = [];
  bool _isBooking = false; // To show a loading indicator on the dialog

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _focusedDay = today;
    _selectedDay = normalizeDate(today);
    _updateAvailableDesks();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = normalizeDate(selectedDay);
        _focusedDay = focusedDay;
        _updateAvailableDesks();
      });
    }
  }

  void _updateAvailableDesks() {
    final normalizedSelectedDay = normalizeDate(_selectedDay);
    final availableDeskIds =
        widget.location.dailyDeskAvailability[normalizedSelectedDay] ?? [];
    _availableDesksForSelectedDay = widget.location.allDesks
        .where((desk) => availableDeskIds.contains(desk.id))
        .toList();
  }

  Future<void> _showBookingDialog(Desk desk, DateTime date) async {
    // Use a ValueNotifier for the loading state within the dialog if needed,
    // or manage it via _isBooking and a StatefulWidget for the dialog content.
    // For simplicity, we'll use _isBooking for now, which requires the dialog
    // to be rebuilt if the state changes while it's open.
    // A more robust way for dialog-specific state is a StatefulBuilder or a dedicated StatefulWidget.

    return showDialog<void>(
      context: context,
      barrierDismissible: !_isBooking, // Prevent dismissing while "booking"
      builder: (BuildContext dialogContext) {
        // Using StatefulBuilder to manage the loading state within the dialog itself
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Confirm Booking'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  const Text('Are you sure you want to book:'),
                  const SizedBox(height: 8),
                  Text('Desk: ${desk.name} (${desk.type})',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Location: ${widget.location.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      'Date: ${MaterialLocalizations.of(context).formatShortDate(date)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (_isBooking) ...[
                    const SizedBox(height: 20),
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 10),
                    const Center(child: Text("Processing booking...")),
                  ]
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: _isBooking
                    ? null
                    : () {
                        // Disable if booking
                        Navigator.of(dialogContext).pop();
                      },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isBooking
                    ? null
                    : () async {
                        // Disable if booking
                        setDialogState(() {
                          _isBooking = true;
                        });

                        // Simulate API call for booking
                        bool bookingSuccess = await _processBooking(desk, date);

                        // Important: Check if the dialog is still mounted before trying to pop or show SnackBar
                        if (!dialogContext.mounted) return;

                        Navigator.of(dialogContext).pop(); // Close dialog

                        // Show SnackBar based on booking result
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              bookingSuccess
                                  ? 'Successfully booked ${desk.name} for ${MaterialLocalizations.of(context).formatShortDate(date)}!'
                                  : 'Failed to book ${desk.name}. Please try again.',
                            ),
                            backgroundColor:
                                bookingSuccess ? Colors.green : Colors.red,
                          ),
                        );

                        if (bookingSuccess) {
                          // OPTIONAL: Update UI to reflect booking (e.g., remove desk from available list)
                          // This requires modifying the dummy data or having a real backend.
                          // For now, we just show a message.
                          // If you were to update, you'd need to:
                          // 1. Modify widget.location.dailyDeskAvailability
                          // 2. Call _updateAvailableDesks()
                          // 3. Call setState(() {}); in the main screen's state
                          _handleSuccessfulBooking(desk, date);
                        }

                        // Reset booking state for the next dialog instance (if the dialog is shown again)
                        // This _isBooking is part of the _SingleLocationScreenState, so it persists.
                        // If we were using a ValueNotifier specific to the dialog, it would be cleaner.
                        // For now, we'll reset it after the dialog is fully handled.
                        // We need to ensure this setState is for the main screen if _isBooking is from there.
                        if (mounted) {
                          // Check if the main screen state is still mounted
                          setState(() {
                            _isBooking = false;
                          });
                        }
                      },
                child: _isBooking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Confirm'),
              ),
            ],
          );
        });
      },
    ).then((_) {
      // This ensures _isBooking is reset if the dialog is dismissed by tapping outside (if barrierDismissible is true and not booking)
      // or by Android back button.
      if (mounted && _isBooking) {
        // Check if the main screen state is still mounted
        setState(() {
          _isBooking = false;
        });
      }
    });
  }

  // Simulate booking process
  Future<bool> _processBooking(Desk desk, DateTime date) async {
    // In a real app, this would be an API call:
    // try {
    //   final response = await apiService.post('bookings', body: {
    //     'deskId': desk.id,
    //     'locationId': widget.location.id,
    //     'date': date.toIso8601String().substring(0, 10),
    //     'userId': 'currentUser' // or get from auth service
    //   });
    //   return true; // if response is successful
    // } catch (e) {
    //   print("Booking error: $e");
    //   return false;
    // }

    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    // Simulate random success/failure
    return DateTime.now().second % 2 == 0;
  }

  void _handleSuccessfulBooking(Desk bookedDesk, DateTime date) {
    // This is where you'd update your local data if not using a live backend
    // For this demo, we'll modify the dummy data. This is NOT ideal for production
    // as the router holds the "source of truth" for dummy data.
    // A proper state management solution is needed for robust updates.

    final normalizedDate = normalizeDate(date);
    if (widget.location.dailyDeskAvailability.containsKey(normalizedDate)) {
      widget.location.dailyDeskAvailability[normalizedDate]
          ?.remove(bookedDesk.id);
      // Since dailyDeskAvailability is part of widget.location, and widget.location
      // comes from the router, this modification is on a copy if the router
      // passes a new instance each time. If it's a reference, it might work.
      // This highlights the need for better state management.
      _updateAvailableDesks(); // Re-filter the list
      if (mounted) {
        setState(() {}); // Trigger a rebuild of the SingleLocationScreen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.location.name),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: normalizeDate(
                DateTime.now().subtract(const Duration(days: 365))),
            lastDay:
                normalizeDate(DateTime.now().add(const Duration(days: 365))),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            calendarFormat: CalendarFormat.month,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Available Desks on ${MaterialLocalizations.of(context).formatShortDate(_selectedDay)}:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: _availableDesksForSelectedDay.isEmpty
                ? const Center(child: Text('No desks available on this day.'))
                : ListView.builder(
                    itemCount: _availableDesksForSelectedDay.length,
                    itemBuilder: (context, index) {
                      final desk = _availableDesksForSelectedDay[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 4.0),
                        child: ListTile(
                          leading: Icon(desk.type == "Standing"
                              ? Icons.desk_outlined
                              : Icons.chair_outlined),
                          title: Text(desk.name),
                          subtitle: Text('Type: ${desk.type}'),
                          trailing: ElevatedButton(
                            onPressed: () {
                              _showBookingDialog(
                                  desk, _selectedDay); // Call the dialog
                            },
                            child: const Text('Book'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
