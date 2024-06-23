import 'package:dental_key/dental_portal/mainscreen/my_appointments.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

class AppointmentsCartPage extends StatefulWidget {
  final Map<String, dynamic> selectedSlot;
  final DateTime selectedDate;
  final String slotDurationDisplay;
  final String accessToken;

  AppointmentsCartPage({
    required this.selectedSlot,
    required this.selectedDate,
    required this.slotDurationDisplay,
    required this.accessToken,
  });

  @override
  _AppointmentsCartPageState createState() => _AppointmentsCartPageState();
}

class _AppointmentsCartPageState extends State<AppointmentsCartPage> {
  double requestedTotalPrice = 0;
  Map<String, dynamic>? _selectedPaymentMethod;
  List<dynamic> _paymentMethods = [];
  String? _userId;
  bool _isCheckingOut = false;
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _furtherInformationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPaymentMethods();
    _extractUserIdFromToken();
    _calculaterequestedTotalPrice();
  }

  void _calculaterequestedTotalPrice() {
    setState(() {
      requestedTotalPrice = double.parse(
          widget.selectedSlot['price'].replaceAll(RegExp(r'[^0-9.]'), ''));
    });
  }

  Future<void> _fetchPaymentMethods() async {
    final response = await http.get(
      Uri.parse(
          'https://dental-key-738b90a4d87a.herokuapp.com/appointments_with_dr_rehan/payment-methods/'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _paymentMethods = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load payment methods');
    }
  }

  void _extractUserIdFromToken() {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.accessToken);
    setState(() {
      _userId = decodedToken['user_id'];
    });
  }

  Future<void> _showPaymentMethods(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Payment Method'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please do not select Card Payment, it is not set for now.',
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 10),
              for (var method in _paymentMethods)
                ListTile(
                  title: Text(method['name']),
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = method;
                    });
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _checkout() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to decode user ID from token')),
      );
      return;
    }

    setState(() {
      _isCheckingOut = true;
    });

    final url = Uri.parse(
        'https://dental-key-738b90a4d87a.herokuapp.com/appointments_with_dr_rehan/appointment-requests/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.accessToken}',
      },
      body: jsonEncode({
        'availability_id': widget.selectedSlot['id'].toString(),
        'payment_method': _selectedPaymentMethod?['code'],
        'booked_by': _userId,
        'subject': _subjectController.text,
        'further_information': _furtherInformationController.text,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment successfully requested!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => myappointments(accessToken: widget.accessToken),
        ),
      );
    } else {
      print('Failed to request appointment: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to request appointment: ${response.body}')),
      );
    }

    setState(() {
      _isCheckingOut = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Stack(children: [
        // Background image with transparency
        Opacity(
          opacity: 0.2, // Set the desired opacity here
          child: Align(
            alignment: Alignment(0.0,
                0.6), // Custom alignment between bottom (1.0) and center (0.0)
            child: Image.asset(
              'assets/images/cart_back.png',
              width: 250, // Set the desired width
              height: 250, // Set the desired height
            ),
          ),
        ),
        ListView(
          padding: EdgeInsets.all(8.0),
          children: [
            Card(
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.calendar_today, size: 50),
                title: Text(
                  'From: ${widget.selectedSlot['start_time']} To: ${widget.selectedSlot['end_time']}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price: GBP ${widget.selectedSlot['price']}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Date: ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Slot Duration: ${widget.slotDurationDisplay}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Mode: ${widget.selectedSlot['meeting_modes_display'].join(', ')}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _furtherInformationController,
                decoration: InputDecoration(
                  labelText: 'Further Information',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),
            if (_selectedPaymentMethod != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Selected Payment Method: ${_selectedPaymentMethod?['name']}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ]),
      bottomNavigationBar: requestedTotalPrice > 0.0
          ? Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.grey[200],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Total Price: GBP ${requestedTotalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () => _showPaymentMethods(context),
                    child: Text('Select Payment Method'),
                  ),
                  SizedBox(height: 16.0),
                  if (_selectedPaymentMethod != null)
                    ElevatedButton(
                      onPressed: () => _checkout(),
                      child: Text('Checkout'),
                    ),
                ],
              ),
            )
          : SizedBox(),
    );
  }
}
