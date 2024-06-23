import 'package:dental_key/dental_portal/mainscreen/dentalportal_main.dart';
import 'package:dental_key/dental_portal/services/BDS_World/BDS_World.dart';
import 'package:dental_key/dental_portal/services/career_pathways/career_pathways_homepage.dart';
import 'package:dental_key/dental_portal/services/display_dental_clinic/Display_dental_clinic.dart';
import 'package:dental_key/dental_portal/services/ips_books/IPS_Books.dart';
import 'package:dental_key/dental_portal/services/ug_exams_tests/01_tests_homepage.dart';
import 'package:dental_key/dental_portal/services/ug_helping_material/UG_helping_material.dart';
import 'package:dental_key/dental_portal/services/dental_key_library/01_dkl_homepage.dart';
import 'package:dental_key/dental_portal/services/video_guidelines/video_guidelines.dart';
import 'package:dental_key/dental_portal/services/make_appointment_with_Rehan/appointments_cart_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class appointmentswithdrrehan extends StatefulWidget {
  final String accessToken;
  appointmentswithdrrehan({required this.accessToken});

  @override
  _appointmentswithdrrehanState createState() =>
      _appointmentswithdrrehanState();
}

class _appointmentswithdrrehanState extends State<appointmentswithdrrehan> {
  String? _selectedSlotDuration;
  DateTime? _selectedDate;
  List<dynamic> _availableSlots = [];
  bool _isLoading = false; // Add this state
  bool _hasSearched = false; // Add this state

  final List<Map<String, String>> _slotDurations = [
    {'value': '1', 'display': '10 Minutes'},
    {'value': '2', 'display': '20 Minutes'},
    {'value': '3', 'display': '30 Minutes'},
    {'value': '4', 'display': '40 Minutes'},
    {'value': '5', 'display': '60 Minutes'},
    {'value': '6', 'display': '120 Minutes'},
  ];

  void _fetchAvailableSlots() async {
    if (_selectedSlotDuration != null && _selectedDate != null) {
      setState(() {
        _isLoading = true; // Set loading to true
        _hasSearched = true; // Set has searched to true
      });

      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final response = await http.get(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/appointments_with_dr_rehan/availability-slots?slot_duration=$_selectedSlotDuration&date=$dateStr'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      setState(() {
        _isLoading = false; // Set loading to false after the response
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData); // Log the response to verify its structure

        if (responseData is List) {
          setState(() {
            _availableSlots = responseData;
          });
        } else {
          // Handle the case where the response is not a list
          setState(() {
            _availableSlots = [];
          });
          // Optionally, show a message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No available slots found.')),
          );
        }
      } else {
        // Handle errors
        setState(() {
          _availableSlots = [];
        });
        // Optionally, show a message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to load available slots. Please try again.')),
        );
      }
    } else {
      setState(() {
        _hasSearched =
            true; // Set has searched to true even if search criteria is missing
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Container 1: containing asset image
            Container(
              width: 150,
              height: 300,
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                color: Color(0xFF385A92),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/rehanappointment.png',
                        width: 150,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.white,
              thickness: 3.0,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to the desired class, e.g., BottomNavigation
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DentalPortalMain(
                                accessToken: widget.accessToken,
                              ),
                            ),
                          );
                        },
                        child: const Row(
                          children: [
                            Icon(
                              Icons.arrow_back,
                              size: 30,
                              color: Colors.black,
                            ),
                            Icon(
                              Icons.home,
                              size: 30,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    _buildContainer(
                      Image.asset(
                        'assets/images/BDS_World_logo.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      () {
                        // Navigate to the desired class, e.g., BottomNavigation
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  BDSWorld(accessToken: widget.accessToken)),
                        );
                      },
                    ),
                    SizedBox(width: 20),
                    _buildContainer(
                      Image.asset(
                        'assets/images/ips_logo.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      () {
                        // Navigate to the desired class, e.g., BottomNavigation
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  IPS(accessToken: widget.accessToken)),
                        );
                      },
                    ),
                    SizedBox(width: 20),
                    _buildContainer(
                      Image.asset(
                        'assets/images/career_options.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      () {
                        // Navigate to the desired class, e.g., BottomNavigation
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DentalCareerPathways(
                                  accessToken: widget.accessToken)),
                        );
                      },
                    ),
                    SizedBox(width: 20),
                    _buildContainer(
                      Image.asset(
                        'assets/images/UGTests.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      () {
                        // Navigate to the desired class, e.g., BottomNavigation
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ugTestsExams(
                                  accessToken: widget.accessToken)),
                        );
                      },
                    ),
                    SizedBox(width: 20),
                    _buildContainer(
                      Image.asset(
                        'assets/images/helping_material.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      () {
                        // Navigate to the desired class, e.g., BottomNavigation
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ugHelpingMaterial(
                                  accessToken: widget.accessToken)),
                        );
                      },
                    ),
                    SizedBox(width: 20),
                    _buildContainer(
                      Image.asset(
                        'assets/images/free_books.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      () {
                        // Navigate to the desired class, e.g., BottomNavigation
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DKLlibrary(accessToken: widget.accessToken)),
                        );
                      },
                    ),
                    SizedBox(width: 20),
                    _buildContainer(
                      Image.asset(
                        'assets/images/multimedia.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      () {
                        // Navigate to the desired class, e.g., BottomNavigation
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => videoguidelines(
                                  accessToken: widget.accessToken)),
                        );
                      },
                    ),
                    SizedBox(width: 20),
                    _buildContainer(
                      Image.asset(
                        'assets/images/dental_unit.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      () {
                        // Navigate to the desired class, e.g., BottomNavigation
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => displayDentalClinic(
                                  accessToken: widget.accessToken)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 30.0, bottom: 20),
              child: Container(
                width: 150,
                height: 1,
                color: Colors.black, // Color of the line
              ),
            ),
            Container(
              child: Center(
                child: Text(
                  'SCHEDULE AN APPOINTMENT WITH',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    decoration: TextDecoration.underline, // Underline text
                  ),
                  textAlign: TextAlign.center, // Align text centrally
                ),
              ),
            ),
            Container(
              child: Center(
                child: Text(
                  'DR. REHAN',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    decoration: TextDecoration.underline, // Underline text
                  ),
                  textAlign: TextAlign.center, // Align text centrally
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedSlotDuration,
                    hint: Text('Select Slot Duration'),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedSlotDuration = newValue;
                      });
                    },
                    items: _slotDurations.map((slot) {
                      return DropdownMenuItem<String>(
                        value: slot['value'],
                        child: Text(slot['display']!),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: _selectedSlotDuration == null
                          ? 'Slot Duration'
                          : 'Selected Slot Duration',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.all(16),
                    ),
                    style: TextStyle(
                      color: const Color.fromARGB(255, 63, 63, 63),
                      fontSize: 16,
                    ),
                    dropdownColor: Colors.white,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.blue,
                    ),
                    iconSize: 24,
                    isExpanded: true,
                    elevation: 16,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) =>
                        value == null ? 'Please select a duration' : null,
                    selectedItemBuilder: (BuildContext context) {
                      return _slotDurations.map((slot) {
                        return Text(
                          slot['display']!,
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(DateTime.now().year + 1),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: _selectedDate == null
                            ? 'Select Date'
                            : 'Selected Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: EdgeInsets.all(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate == null
                                ? 'Select Date'
                                : DateFormat('yyyy-MM-dd')
                                    .format(_selectedDate!),
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedDate == null
                                  ? Colors.black
                                  : Colors.blue,
                            ),
                          ),
                          Icon(Icons.calendar_today, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _fetchAvailableSlots,
                    child: Text('Search'),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isLoading) // Show loader if _isLoading is true
                    Center(
                      child: CircularProgressIndicator(),
                    )
                  else if (!_hasSearched) // Show initial message if not searched
                    Center(
                      child: Text(
                        'Please Select Slot Duration and Date to view available appointments.',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else if (_availableSlots.isNotEmpty)
                    ..._availableSlots.map((slot) {
                      return Card(
                        margin: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  'From: ${slot['start_time']} To: ${slot['end_time']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 5),
                                    Text('Price: GBP ${slot['price']}'),
                                    Text(
                                        'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}'),
                                    Text(
                                        'Slot Duration: ${_slotDurations.firstWhere((element) => element['value'] == _selectedSlotDuration)['display']}'),
                                    Text(
                                        'Mode: ${slot['meeting_modes_display'].join(', ')}'),
                                    SizedBox(height: 10),
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AppointmentsCartPage(
                                                selectedSlot: slot,
                                                selectedDate: _selectedDate!,
                                                slotDurationDisplay: _slotDurations
                                                        .firstWhere((element) =>
                                                            element['value'] ==
                                                            _selectedSlotDuration)[
                                                    'display']!,
                                                accessToken: widget.accessToken,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text('Reserve this slot'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList()
                  else
                    Center(
                      child: Text(
                        'No Slot available for your choice, Please modify your search.',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainer(Widget child, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // Pass the onTap function to GestureDetector
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black),
        ),
        padding: EdgeInsets.all(8),
        child: child,
      ),
    );
  }
}
