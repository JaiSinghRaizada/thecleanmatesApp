import 'package:cleanmates/screens/home/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore package

class AddEvents extends StatefulWidget {
  @override
  _AddEventsState createState() => _AddEventsState();
}

class _AddEventsState extends State<AddEvents> {
  // Variables to store selected date and time
  ValueNotifier<DateTime?> selectedDate = ValueNotifier<DateTime?>(null);
  ValueNotifier<TimeOfDay?> selectedTime = ValueNotifier<TimeOfDay?>(null);
  ValueNotifier<TimeOfDay?> selectedEndTime = ValueNotifier<TimeOfDay?>(null);
  bool isInputVisible = false; // Toggle state
  final TextEditingController hourController = TextEditingController();
  // Text editing controllers for the input fields
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  TextEditingController NewAreaController = TextEditingController();
  TextEditingController NewHnoController = TextEditingController();
  TextEditingController NewPostalCodeController = TextEditingController();
  TextEditingController NewCityController = TextEditingController();
  int selectedCardIndex = -1;

  // Firebase Firestore instance
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Variable to store existing addresses for suggestion
  List<Map<String, dynamic>> existingAddresses = [];

  // Function to fetch existing address data
  Future<void> fetchAddress(String phoneNo) async {
    try {
      // Fetch existing addresses for the provided phone number
      DocumentSnapshot snapshot = await firestore
          .collection('addresses')
          .doc(phoneNo)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>? ?? {};
        print('Fetched data: $data');
        // Retrieve the 'address' field safely
        List<dynamic> addresses = data['address'] ?? [];

        // Loop through and process each address
        List<Map<String, dynamic>> validAddresses = [];
        for (var address in addresses) {
          if (address != null && address is Map<String, dynamic>) {

            validAddresses.add(Map<String, dynamic>.from(address));
          }
        }

        setState(() {
          existingAddresses = validAddresses; // Store all valid addresses in the state
        });
        print(existingAddresses);
      } else {
        setState(() {
          existingAddresses = [];
        });
      }
    } catch (e) {
      print('Error fetching addresses: $e');
    }
  }

  Future<void> fetchName(String phoneNo) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('clients')
          .where('phone_number', isEqualTo: phoneNo)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          nameController.text = snapshot.docs.first['name'] ?? 'Unknown';
        });
      } else {
        setState(() {
          nameController.text = '';
        });
      }
    } catch (e) {
      print('Error fetching name: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Add Events',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFF23D49),
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phone No',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  decoration: InputDecoration(
                    hintText: 'Enter your phone number',
                    suffixIcon: Icon(Icons.phone, color: Colors.white),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    if (value.length == 10) {
                      // When the phone number is entered, fetch address data
                      fetchAddress(value);
                      fetchName(value);
                    } else {
                      setState(() {
                        existingAddresses =
                        [];
                        selectedCardIndex = -1;
                      });
                    }
                  },
                ),

                const Text(
                  'Name',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your Name',
                    suffixIcon: Icon(Icons.phone, color: Colors.white),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor:
                        WidgetStateProperty.all<Color>(Colors.white),
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(
                          vertical: screenHeight * 0.01,
                          horizontal: screenWidth * 0.03),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          scrollable: true,
                          title: Text('Add Address'),
                          content: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Form(
                              child: Column(
                                children: <Widget>[
                                  TextFormField(
                                    controller: NewAreaController,
                                    decoration: InputDecoration(
                                      labelText: 'Enter Area',
                                      icon: Icon(Icons.home),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: screenHeight * 0.01,
                                          horizontal: screenHeight * 0.01),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: NewHnoController,
                                    decoration: InputDecoration(
                                      labelText: 'Enter Hno',
                                      icon: Icon(Icons.home),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: screenHeight * 0.01,
                                          horizontal: screenHeight * 0.01),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: NewPostalCodeController,
                                    decoration: InputDecoration(
                                      labelText: 'Enter Postal Code',
                                      icon: Icon(Icons.home),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: screenHeight * 0.01,
                                          horizontal: screenHeight * 0.01),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: NewCityController,
                                    decoration: InputDecoration(
                                      labelText: 'Enter city',
                                      icon: Icon(Icons.home),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: screenHeight * 0.01,
                                          horizontal: screenHeight * 0.01),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                              child: const Text("Submit"),
                              onPressed: () async {
                                if (phoneController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Phone number is required'),
                                    ),
                                  );
                                } else if (NewAreaController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Area is required'),
                                    ),
                                  );
                                } else if (NewAreaController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('House number is required'),
                                    ),
                                  );
                                } else if (NewPostalCodeController
                                    .text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Postal code is required'),
                                    ),
                                  );
                                } else if (NewCityController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('City is required'),
                                    ),
                                  );
                                } else if (nameController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Name is required'),
                                    ),
                                  );
                                } else {
                                  try {
                                    String phoneNo = phoneController.text;
                                    String name = nameController.text;

                                    // Check if the client exists
                                    DocumentReference clientRef = firestore
                                        .collection('clients')
                                        .doc(phoneNo);

                                    DocumentSnapshot clientSnapshot =
                                        await clientRef.get();

                                    if (!clientSnapshot.exists) {
                                      await clientRef.set({
                                        'phone_number': phoneNo,
                                        'name': name
                                      });
                                    }

                                    DocumentReference addressRef = firestore
                                        .collection('addresses')
                                        .doc(phoneNo);

                                    DocumentSnapshot addressSnapshot =
                                    await addressRef.get();

                                    if (!addressSnapshot.exists) {
                                      await addressRef.set({
                                        'address': []
                                      });
                                    }

                                    Map<String, String> newAddress = {
                                      'area': NewAreaController.text,
                                      'hno': NewHnoController.text,
                                      'postal_code': NewPostalCodeController.text,
                                      'city': NewCityController.text,
                                    };

                                    FirebaseFirestore.instance
                                        .collection('addresses')
                                        .doc(phoneNo)
                                        .set({
                                      "address": FieldValue.arrayUnion([newAddress])
                                    }, SetOptions(merge: true))
                                        .then((value) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Address Added Successfully')),
                                      );
                                    })
                                        .catchError((error) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to add address: $error')),
                                      );
                                    });


                                    // await firestore.collection('addresses').doc(phoneNo).add({
                                    //   'address': {
                                    //     'area': NewAreaController.text,
                                    //     'hno': NewHnoController.text,
                                    //     'postal_code': NewPostalCodeController.text,
                                    //     'city': NewCityController.text,
                                    //   },
                                    // });


                                    ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Address Added Successfully'),
                                        ),
                                      );

                                    // } else {
                                    //   ScaffoldMessenger.of(context)
                                    //       .showSnackBar(
                                    //     const SnackBar(
                                    //       content:
                                    //           Text('Address Already Exists'),
                                    //     ),
                                    //   );
                                    // }

                                    NewAreaController.clear();
                                    NewHnoController.clear();
                                    NewPostalCodeController.clear();
                                    NewCityController.clear();
                                    Navigator.of(context).pop();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Failed to add address'),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const SizedBox(
                    width: 160, // Set the desired width of the button
                    height: 40, // Set the desired height of the button
                    child: Center(
                      child: Text(
                        'Add Address',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                // Address suggestion list
                if (existingAddresses.isNotEmpty) ...[
                  const Text(
                    'Existing Address Suggestions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: existingAddresses.length,
                    itemBuilder: (context, index) {
                      final address = existingAddresses[index];
                      final isSelected = index == selectedCardIndex;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCardIndex = index; // Update the selected card index
                          });
                        },
                        child: Card(
                          color: isSelected ? Colors.lightBlue[100] : Colors.white,
                          child: ListTile(
                            title: Text(address['area'] ?? 'No area'),
                            subtitle: Text(
                                '${address['city'] ?? 'No city'}, ${address['postal_code'] ?? 'No postal code'}'),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                const Text(
                  'Select Date',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder<DateTime?>(
                  valueListenable: selectedDate,
                  builder: (context, value, child) {
                    return GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (pickedDate != null) {
                          selectedDate.value = pickedDate;
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFF23D49)),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              value != null
                                  ? DateFormat('EEE, d MMM').format(value)
                                  : 'Tap to select a date',
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    value != null ? Colors.black : Colors.grey,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: Color(0xFFF23D49),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                // Select Time Section
                const Text(
                  'Select Time',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder<TimeOfDay?>(
                  valueListenable: selectedTime,
                  builder: (context, value, child) {
                    return GestureDetector(
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          selectedTime.value = pickedTime;
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFF23D49)),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              value != null
                                  ? value.format(context)
                                  : 'Tap to select a time',
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    value != null ? Colors.black : Colors.grey,
                              ),
                            ),
                            const Icon(
                              Icons.access_time,
                              color: Color(0xFFF23D49),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                const Text(
                  'Select End Time (By default 2 hours)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Edit End Time:'),
                    Switch(
                      value: isInputVisible,
                      onChanged: (value) {
                        setState(() {
                          isInputVisible = value;
                          if (!value) {
                            hourController.text = '2';
                          }
                        });
                      },
                      activeColor: const Color(0xFFF23D49),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (isInputVisible)
                  TextField(
                    controller: hourController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter number of hours (default: 2)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFF23D49)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFF23D49)),
                      ),
                    ),
                  ),

                const SizedBox(height: 130),
              ],
            ),
          ),

          // Fixed bottom button
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (phoneController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Phone number is required'),
                        ),
                      );
                    } else if (selectedCardIndex == -1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Address is required'),
                        ),
                      );
                    } else if (selectedDate.value == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Date selection is required'),
                        ),
                      );
                    } else if (selectedTime.value == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Start Time selection is required'),
                        ),
                      );
                    } else if (nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Name is required'),
                        ),
                      );
                    } else {
                      DateTime now = DateTime.now();
                      DateTime selectedDateTime = DateTime(
                        selectedDate.value!.year,
                        selectedDate.value!.month,
                        selectedDate.value!.day,
                        selectedTime.value!.hour,
                        selectedTime.value!.minute,
                      );
                      int timeInMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

                      if (selectedDateTime.isBefore(now)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Selected date and time cannot be in the past'),
                          ),
                        );
                      }else {
                        try {
                          String phoneNo = phoneController.text;
                          String name = nameController.text;

                          // Check if the client exists
                          DocumentReference clientRef = firestore.collection('clients').doc(phoneNo);
                          DocumentSnapshot clientSnapshot = await clientRef.get();

                          if (!clientSnapshot.exists) {
                            await clientRef.set({'phone_number': phoneNo, 'name': name});
                          }

                          // Convert the selected date and time to Firestore timestamp
                          DateTime eventStartDateTime = DateTime(
                            selectedDate.value!.year,
                            selectedDate.value!.month,
                            selectedDate.value!.day,
                            selectedTime.value!.hour,
                            selectedTime.value!.minute,
                          );
                          DateTime eventEndDateTime = eventStartDateTime.add(
                            Duration(hours: int.tryParse(hourController.text) ?? 2),
                          );
                          if (hourController.text.isEmpty) {
                            eventEndDateTime = eventStartDateTime.add(
                              Duration(hours: 2),
                            );
                          }

                          // Fetch all events with the same date and time
                          QuerySnapshot overlappingEvents = await firestore
                              .collection('events')
                              .where('event_start_date_time', isLessThanOrEqualTo: eventEndDateTime)
                              .where('event_end_date_time', isGreaterThanOrEqualTo: eventStartDateTime)
                              .get();

                          //! Maximum Limit of add events at one time
                          const int maxEventsAtSameTime = 1;

                          if (overlappingEvents.docs.length >= maxEventsAtSameTime) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Cannot add event. Maximum of $maxEventsAtSameTime events already scheduled for this time.'),
                              ),
                            );
                            return;
                          }

                          // Add the new event to the events collection
                          await firestore.collection('events').add({
                            'phone_number': phoneNo,
                            'event_start_date_time': eventStartDateTime,
                            'event_end_date_time': eventEndDateTime,
                            'event_name': 'Event',
                            'addressIndex': selectedCardIndex
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Event Added Successfully')),
                          );

                          // Clear the controllers and reset values
                          phoneController.clear();
                          nameController.clear();
                          selectedDate.value = null;
                          selectedTime.value = null;
                          selectedCardIndex = -1;

                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Event Added Successfully'),
                              content: const Text('Do You want to add More Events?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('No'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Yes'),
                                ),
                              ],
                            ),
                          );
                        }
                        catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to add event'),
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF23D49),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text(
                    'Add Event',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
