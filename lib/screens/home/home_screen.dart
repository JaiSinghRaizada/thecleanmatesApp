import 'package:cleanmates/screens/add_events/add_events.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Get the start and end of today's date for filtering
    DateTime startOfDay =
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime endOfDay = startOfDay.add(Duration(days: 1));

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Today\'s Events',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFF23D49),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events') // Your collection name
            .where('event_start_date_time', isGreaterThanOrEqualTo: startOfDay)
            .where('event_start_date_time',
            isLessThan: endOfDay) // Filter for today's events
            .snapshots(), // Real-time listener for Firestore updates
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No events available today'));
          }

          var events = snapshot.data!.docs;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              var eventData = events[index].data() as Map<String, dynamic>;
              var event = eventData['event'];
              var phoneNumber = eventData['phone_number'];
              var eventDateTime =
              (eventData['event_start_date_time'] as Timestamp).toDate();
              var eventTime = DateFormat('hh:mm a').format(eventDateTime);
              var eventName = eventData['event_name'];

              return ListTile(
                title: Text(eventName),
                subtitle: Text('Time: $eventTime\nPhone: $phoneNumber'),
              );
            },
          );
        },

      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEvents()),
          );
          print("Floating Action Button Pressed");
        },
        backgroundColor: Color(0xFFF23D49),
        child: const Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}
