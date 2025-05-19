import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/models.dart';
import 'locations_screen.dart'; // For LocationItem, Desk, normalizeDate

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
  bool _isBooking = false;

  // Define a breakpoint for switching between layouts
  static const double kTabletBreakpoint = 720.0; // Adjust as needed

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
        _focusedDay = focusedDay; // Keep focused day in sync with selection
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
    return showDialog<void>(
      context: context,
      barrierDismissible: !_isBooking,
      builder: (BuildContext dialogContext) {
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
                        setDialogState(() {
                          _isBooking = true;
                        });
                        bool bookingSuccess = await _processBooking(desk, date);
                        if (!dialogContext.mounted) return;
                        Navigator.of(dialogContext).pop();
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
                          _handleSuccessfulBooking(desk, date);
                        }
                        if (mounted) {
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
      if (mounted && _isBooking) {
        setState(() {
          _isBooking = false;
        });
      }
    });
  }

  Future<bool> _processBooking(Desk desk, DateTime date) async {
    await Future.delayed(const Duration(seconds: 2));
    return DateTime.now().second % 2 == 0;
  }

  void _handleSuccessfulBooking(Desk bookedDesk, DateTime date) {
    final normalizedDate = normalizeDate(date);
    if (widget.location.dailyDeskAvailability.containsKey(normalizedDate)) {
      widget.location.dailyDeskAvailability[normalizedDate]
          ?.remove(bookedDesk.id);
      _updateAvailableDesks();
      if (mounted) {
        setState(() {});
      }
    }
  }

  // --- Widget Builders for Layout ---
  Widget _buildCalendarSection() {
    return Card(
      // Wrap calendar in a card for better visual separation
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Inner padding for the card
        child: TableCalendar(
          firstDay:
              normalizeDate(DateTime.now().subtract(const Duration(days: 365))),
          lastDay: normalizeDate(DateTime.now().add(const Duration(days: 365))),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: _onDaySelected,
          calendarFormat: CalendarFormat.month,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            // Potentially make cells smaller for a tighter calendar
            // cellMargin: EdgeInsets.all(2.0),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
              // weekendStyle: TextStyle(color: Colors.red[600]),
              ),
          onPageChanged: (focusedDay) {
            // Update focusedDay if user swipes month, but don't change selectedDay
            setState(() {
              _focusedDay = focusedDay;
            });
          },
        ),
      ),
    );
  }

  Widget _buildAvailabilitySummary() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Desks Available on',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              MaterialLocalizations.of(context).formatMediumDate(_selectedDay),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '${_availableDesksForSelectedDay.length}',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
            Text(
              _availableDesksForSelectedDay.length == 1 ? 'Desk' : 'Desks',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeskListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Available Desks on ${MaterialLocalizations.of(context).formatShortDate(_selectedDay)}:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: _availableDesksForSelectedDay.isEmpty
              ? const Center(
                  child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No desks available on this day.',
                      style: TextStyle(fontSize: 16)),
                ))
              : ListView.builder(
                  padding: const EdgeInsets.only(
                      right: 8.0, left: 8.0, bottom: 8.0), // Add some padding
                  itemCount: _availableDesksForSelectedDay.length,
                  itemBuilder: (context, index) {
                    final desk = _availableDesksForSelectedDay[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        leading: Icon(
                            desk.type == "Standing"
                                ? Icons.desk_outlined
                                : Icons.chair_outlined,
                            color: Theme.of(context).primaryColor),
                        title: Text(desk.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Type: ${desk.type}'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            _showBookingDialog(desk, _selectedDay);
                          },
                          child: const Text('Book'),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.location.name),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > kTabletBreakpoint) {
            // --- Wide Screen Layout (Two Columns) ---
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Left Column (Calendar and Summary)
                SizedBox(
                  width: constraints.maxWidth *
                      0.4, // Adjust width as needed (e.g., 350, 400, or percentage)
                  child: SingleChildScrollView(
                    // Allow scrolling if content overflows vertically
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildCalendarSection(),
                        const SizedBox(height: 16),
                        _buildAvailabilitySummary(),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                // Right Column (Desk List)
                Expanded(
                  child: _buildDeskListSection(),
                ),
              ],
            );
          } else {
            // --- Narrow Screen Layout (Single Column) ---
            return SingleChildScrollView(
              // Add scroll for narrow screens
              child: Column(
                children: [
                  _buildCalendarSection(),
                  _buildAvailabilitySummary(), // Summary below calendar
                  const Divider(),
                  // Desk list section needs a defined height or to be non-expanded in SingleChildScrollView
                  // Let's give it a fixed height or make it shrinkwrap for this example
                  SizedBox(
                    height:
                        400, // Or use ConstrainedBox, or make _buildDeskListSection return a non-Expanded widget
                    child: _buildDeskListSection(),
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
