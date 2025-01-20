import 'package:cleanmates/screens/calender_screen/eventTimeScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDate = DateTime.now();
  DateTime? _selectedDate;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  /// Fetch events from Firestore and group them by normalized date
  void _fetchEvents() async {
    FirebaseFirestore.instance.collection('events').snapshots().listen((snapshot) {
      Map<DateTime, List<Map<String, dynamic>>> fetchedEvents = {};

      for (var doc in snapshot.docs) {
        var data = doc.data();
        print('Fetched event: $data'); // Debugging print

        if (data.containsKey('event_start_date_time')) {
          DateTime eventDate = (data['event_start_date_time'] as Timestamp).toDate();

          // Normalize date to remove time component
          DateTime normalizedDate = DateTime.utc(eventDate.year, eventDate.month, eventDate.day);
          if (fetchedEvents[normalizedDate] == null) {
            fetchedEvents[normalizedDate] = [];
          }

          fetchedEvents[normalizedDate]!.add(data);
        }
      }

      setState(() {
        _events = fetchedEvents;
        print('Processed events: $_events'); // Debugging print
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Calendar Events",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF23D49),
      ),
      body: Column(
        children: [
          // Calendar widget
          TableCalendar(
            focusedDay: _focusedDate,
            firstDay: DateTime(2020),
            lastDay: DateTime(2100),
            selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
                _focusedDate = focusedDay;
              });

              DateTime normalizedDate =
              DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day);
              if (_events.containsKey(normalizedDate)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventTimeScreen(
                      date: normalizedDate,
                      events: _events[normalizedDate]!,
                    ),
                  ),
                );
              }
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                DateTime normalizedDay = DateTime.utc(day.year, day.month, day.day);
                if (_events[normalizedDay] != null) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF23D49),
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
            eventLoader: (day) {
              DateTime normalizedDate = DateTime.utc(day.year, day.month, day.day);
              print('Loading events for $normalizedDate'); // Debugging print
              return _events[normalizedDate] ?? [];
            },
          ),
          const SizedBox(height: 10),

          // Event list for selected date
          if (_selectedDate != null) ...[
            Expanded(
              child: ListView(
                children: (_events[DateTime.utc(
                  _selectedDate!.year,
                  _selectedDate!.month,
                  _selectedDate!.day,
                )] ??
                    [])
                    .map((event) {
                  String eventName = event['event_name'];
                  String eventTime = DateFormat('hh:mm a')
                      .format((event['event_start_date_time'] as Timestamp).toDate());
                  return ListTile(
                    title: Text(eventName),
                    subtitle: Text(eventTime),
                  );
                }).toList(),
              ),
            )
          ] else
            const Expanded(
              child: Center(
                child: Text('Select a date to view events.'),
              ),
            ),
        ],
      ),
    );
  }
}
//
// class EventTimeScreen extends StatelessWidget {
//   final DateTime date;
//   final List<Map<String, dynamic>> events;
//
//   const EventTimeScreen({Key? key, required this.date, required this.events})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     Map<String, List<Map<String, dynamic>>> eventsByTime = {};
//
//     for (var event in events) {
//       String time =
//       DateFormat('hh:mm a').format((event['event_start_date_time'] as Timestamp).toDate());
//       eventsByTime[time] = eventsByTime[time] ?? [];
//       eventsByTime[time]!.add(event);
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           DateFormat('yyyy-MM-dd').format(date),
//         ),
//         backgroundColor: const Color(0xFFF23D49),
//       ),
//       body: ListView.builder(
//         itemCount: eventsByTime.keys.length,
//         itemBuilder: (context, index) {
//           String time = eventsByTime.keys.elementAt(index);
//           return Card(
//             child: ListTile(
//               title: Text(time),
//               subtitle: Text(
//                 eventsByTime[time]!
//                     .map((e) => e['event_name'])
//                     .join(', '), // Display all event names
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
