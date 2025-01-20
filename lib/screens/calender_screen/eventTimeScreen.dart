import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EventTimeScreen extends StatelessWidget {
  final DateTime date;
  final List<Map<String, dynamic>> events;

  const EventTimeScreen({Key? key, required this.date, required this.events})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Group events by their start time
    Map<String, List<Map<String, dynamic>>> eventsByTime = {};
    for (var event in events) {
      String time = DateFormat('hh:mm a')
          .format((event['event_start_date_time'] as Timestamp).toDate());
      eventsByTime[time] = eventsByTime[time] ?? [];
      eventsByTime[time]!.add(event);
    }

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            DateFormat('yyyy-MM-dd').format(date),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: const Color(0xFFF23D49),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: eventsByTime.keys.length,
          itemBuilder: (context, index) {
            String time = eventsByTime.keys.elementAt(index);
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Colors.redAccent.shade200,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 6),
                    Text(
                      "Events:",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...eventsByTime[time]!.map(
                          (event) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.event_note,
                              color: Colors.blueGrey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                event['event_name'],
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Address:",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...eventsByTime[time]!.map(
                          (event) {
                        final address = event['address'] as Map<String, dynamic>;
                        final String formattedAddress =
                            "${address['hno']}, ${address['area']}, ${address['city']}, ${address['postal_code']}";
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.home,
                                color: Colors.blueGrey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  formattedAddress,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
