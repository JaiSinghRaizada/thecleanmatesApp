import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EventTimeScreen extends StatelessWidget {
  final DateTime date;
  final List<Map<String, dynamic>> events;

  const EventTimeScreen({Key? key, required this.date, required this.events})
      : super(key: key);

  Future<void> _launchMap(BuildContext context, String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final browserUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress');
    if (!await launchUrl(browserUrl)) {
      throw Exception('Could not launch');
    }
  }

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
                    const Text(
                      "Events:",
                      style: TextStyle(
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
                    const Text(
                      "Address:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FutureBuilder<Map<String, dynamic>?>(
                      future: fetchAddress(
                          eventsByTime[time]!.first['phone_number'],
                          eventsByTime[time]!.first['addressIndex']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasData && snapshot.data != null) {
                          final address = snapshot.data!;
                          final String formattedAddress =
                          "${address['hno'] ?? ''}, ${address['area'] ?? ''}, ${address['city'] ?? ''}, ${address['postal_code'] ?? ''}"
                              .trim()
                              .replaceAll(RegExp(r' ,|, ,'), ',');
                          return Row(
                            children: [

                              Expanded(
                                child: Text(
                                  formattedAddress.isNotEmpty
                                      ? formattedAddress
                                      : 'Address not available',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () =>
                                    _launchMap(context, formattedAddress),
                                child: const Icon(
                                  Icons.directions,
                                  color: Colors.blueGrey,
                                  size: 30,
                                ),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
