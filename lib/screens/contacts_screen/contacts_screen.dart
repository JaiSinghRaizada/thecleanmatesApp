import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ContactsScreen extends StatelessWidget {
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
          'Contacts',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFF23D49),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('clients')
            .where('phone_number', isNotEqualTo: null)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No contacts with phone numbers found'));
          }

          var contacts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              var contact = contacts[index];
              var phoneNumber = contact['phone_number'] ?? 'N/A';
              var name = contact['name'] ?? 'N/A';

              return ListTile(
                title: Text(
                  name ,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Phone: +91 $phoneNumber'),
              );
            },
          );
        },
      ),
    );
  }
}
