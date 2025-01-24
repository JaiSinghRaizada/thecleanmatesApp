import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cleanmates/screens/add_events/add_events.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {

  Future<Map<String, dynamic>?> fetchAddress(
      String phoneNumber, int addressIndex) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('addresses')
          .doc(phoneNumber)
          .get();

      if (documentSnapshot.exists) {
        List<dynamic> addresses = documentSnapshot['address'];
        if (addressIndex < addresses.length) {
          return addresses[addressIndex];
        } else {
          print('Invalid address index');
          return null;
        }
      } else {
        print('Document not found');
        return null;
      }
    } catch (e) {
      print('Error fetching address: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    DateTime startOfDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
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
            .where('event_start_date_time', isLessThan: endOfDay)
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
              var eventName = eventData['event_name'];
              var phoneNumber = eventData['phone_number'];
              var eventDateTime = (eventData['event_start_date_time'] as Timestamp).toDate();
              var eventTime = DateFormat('hh:mm a').format(eventDateTime);
              var addressIndex = eventData['addressIndex'];

              return ListTile(
                title: Text(eventName),
                trailing: GestureDetector(
                  onTap: () async {
                    Uri url = Uri(scheme: "tel", path: phoneNumber);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      print("Can't open dial pad.");
                    }
                  },
                  child: Column(
                    children: [
                      Text(
                        'Phone: $phoneNumber',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Time: $eventTime'),
                    const SizedBox(height: 6),
                    FutureBuilder<Map<String, dynamic>?>( // Fetch and display address
                      future: fetchAddress(phoneNumber, addressIndex),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasData && snapshot.data != null) {
                          final address = snapshot.data!;
                          final String formattedAddress =
                          "${address['hno'] ?? ''}, ${address['area'] ?? ''}, ${address['city'] ?? ''}, ${address['postal_code'] ?? ''}"
                              .trim()
                              .replaceAll(RegExp(r' ,|, ,'), ',');

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Address: $formattedAddress',
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                            ],
                          );
                        } else {
                          return const Text('Address not available');
                        }
                      },
                    ),
                  ],
                ),
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
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _launchMap(BuildContext context, String address) async {
    final String googleMapsUrl = "https://www.google.com/maps/search/?q=$address";
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      print("Could not launch maps");
    }
  }
}
