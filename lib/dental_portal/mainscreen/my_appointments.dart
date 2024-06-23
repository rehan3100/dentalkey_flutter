import 'dart:async';
import 'package:dental_key/dental_portal/mainscreen/dentalportal_main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dental_key/dental_portal/services/make_appointment_with_Rehan/Appointments_BankTransferform.dart';
import 'package:url_launcher/url_launcher.dart';

class myappointments extends StatefulWidget {
  final String accessToken;

  myappointments({required this.accessToken});

  @override
  _myappointmentsState createState() => _myappointmentsState();
}

class _myappointmentsState extends State<myappointments> {
  List<dynamic> _reservedSlots = [];
  bool _isLoading = true; // Add this line

  @override
  void initState() {
    super.initState();
    _fetchReservedSlots();
  }

  final Map<String, String> paymentMethodMap = {
    'OB': 'Online Bank Transfer',
    'BB': 'Card Payment',
  };

  Future<void> _fetchReservedSlots() async {
    final response = await http.get(
      Uri.parse(
          'https://dental-key-738b90a4d87a.herokuapp.com/appointments_with_dr_rehan/user-requests/'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          _reservedSlots = json.decode(response.body);
          _reservedSlots.sort((a, b) => DateTime.parse(b['booked_at'])
              .compareTo(DateTime.parse(a['booked_at'])));
          _isLoading = false; // Add this line
        });
      }
    } else {
      // Handle errors
      setState(() {
        _isLoading = false; // Add this line
      });
    }
  }

  Future<bool> _onWillPop() async {
    // Redirect to DentalPortalMain when back button is pressed
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              DentalPortalMain(accessToken: widget.accessToken)),
    );
    return false;
  }

  Future<void> refreshpage() async {
    await _fetchReservedSlots();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Appointments'),
          automaticallyImplyLeading: true, // Hides the back arrow
          centerTitle: true, // Centers the title
          backgroundColor:
              Color(0xFF385A92), // Set the background color of the AppBar
          titleTextStyle: TextStyle(
            color: Colors.white, // Set the text color of the AppBar title
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: RefreshIndicator(
          onRefresh: refreshpage,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 16, left: 16, top: 10),
                child: Text(
                  'Please do not perform payment by clicking "Pay Now" button, for the order if order\'s TIME IS UP, but still seeing Pay Now Button',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  right: 16,
                  left: 16,
                ),
                child: Text(
                  'After 2 to 3 minutes, Pay Now button will be vanished automatically.',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 89, 89, 89),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 16, left: 16, bottom: 10),
                child: Text(
                  'After ending the timer, you can re-select the same appointment by going to Make Appointment',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 89, 89, 89),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _reservedSlots.isEmpty
                        ? Center(
                            child: Text('No Appointment has been made yet!'))
                        : ListView.builder(
                            itemCount: _reservedSlots.length,
                            itemBuilder: (context, index) {
                              final slot = _reservedSlots[index];
                              final String status =
                                  slot['request_status'] ?? 'Unknown';
                              final String statusDisplay =
                                  slot['request_status_display'] ?? 'Unknown';
                              final String meetingLink =
                                  slot['availability']['meeting_link'] ?? '';
                              final DateTime bookedAt = DateTime.parse(slot[
                                  'booked_at']); // Parse the booked_at time

                              return Padding(
                                padding:
                                    EdgeInsets.all(8.0), // Add padding here
                                child: SizedBox(
                                  width: double
                                      .infinity, // Set width to occupy available space
                                  child: Card(
                                    color: Color.fromARGB(255, 193, 222,
                                        247), // Set background color here
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          title: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  'Slot: ${slot['availability']['start_time']} - ${slot['availability']['end_time']}'),
                                              Text(
                                                  'Date: ${slot['availability']['date']}'),
                                              Text(
                                                  'Price: GBP ${slot['availability']['price']}'),
                                              Text(
                                                  'Payment Method: ${_formatPaymentMethod(slot['payment_method_display'])}'),
                                              Text(
                                                  'Current Order Status: $statusDisplay'),
                                              if (status != 'PD' &&
                                                  status !=
                                                      'OR') // Conditionally add the CountdownTimer
                                                CountdownTimer(
                                                    bookedAt:
                                                        bookedAt), // Add the CountdownTimer widget
                                            ],
                                          ),
                                        ),
                                        if (status !=
                                            'VF') // Hide button if status is VF
                                          Padding(
                                            padding: EdgeInsets.only(
                                                bottom: 8.0,
                                                right: 10.0,
                                                left:
                                                    10.0), // Add top and bottom padding here
                                            child: Container(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: status != 'AP'
                                                    ? null // Set to null to make the button unclickable
                                                    : () {
                                                        // Perform action for unpaid order
                                                        String userId =
                                                            slot['booked_by'];
                                                        String orderId =
                                                            slot['id'];
                                                        String orderPrice =
                                                            slot['availability']
                                                                    ['price']
                                                                .toString();

                                                        // Check the chosen payment method
                                                        String paymentMethod = slot[
                                                            'payment_method_display'];

                                                        // Navigate to different screens based on payment method
                                                        if (paymentMethod ==
                                                            'Card Payment') {
                                                          // Add your card payment handling code here
                                                        } else {
                                                          // Navigate to BankTransferFormScreen (replace with your actual screen)
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  AppointmentsBankTransferForm(
                                                                userId: userId,
                                                                orderId:
                                                                    orderId,
                                                                orderprice:
                                                                    orderPrice,
                                                                accessToken: widget
                                                                    .accessToken,
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                child: Text(status != 'AP'
                                                    ? 'Paid'
                                                    : 'Pay Now'),
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty
                                                          .resolveWith<Color>(
                                                    (Set<MaterialState>
                                                        states) {
                                                      if (states.contains(
                                                          MaterialState
                                                              .pressed)) {
                                                        return Color.fromARGB(
                                                            255,
                                                            255,
                                                            255,
                                                            255); // Color when pressed
                                                      }
                                                      return Color(
                                                          0xFF385A92); // Default color
                                                    },
                                                  ),
                                                  foregroundColor:
                                                      MaterialStateProperty
                                                          .resolveWith<Color>(
                                                    (Set<MaterialState>
                                                        states) {
                                                      if (states.contains(
                                                          MaterialState
                                                              .pressed)) {
                                                        return Color(
                                                            0xFF385A92); // Text and Icon color when pressed
                                                      }
                                                      return Color.fromARGB(
                                                          255,
                                                          255,
                                                          255,
                                                          255); // Default text color
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (status == 'OR')
                                          Padding(
                                            padding: EdgeInsets.only(
                                                bottom: 8.0,
                                                right: 10.0,
                                                left:
                                                    10.0), // Add top and bottom padding here
                                            child: Container(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  if (meetingLink.isNotEmpty) {
                                                    _launchURL(meetingLink);
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              'Meeting link is not available')),
                                                    );
                                                  }
                                                  // Implement your logic to start the meeting
                                                },
                                                child: Text('Start Meeting'),
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty
                                                          .resolveWith<Color>(
                                                    (Set<MaterialState>
                                                        states) {
                                                      if (states.contains(
                                                          MaterialState
                                                              .pressed)) {
                                                        return Color.fromARGB(
                                                            255, 255, 255, 255);
                                                      }
                                                      return Colors.green;
                                                    },
                                                  ),
                                                  foregroundColor:
                                                      MaterialStateProperty
                                                          .resolveWith<Color>(
                                                    (Set<MaterialState>
                                                        states) {
                                                      if (states.contains(
                                                          MaterialState
                                                              .pressed)) {
                                                        return Colors.green;
                                                      }
                                                      return Color.fromARGB(
                                                          255, 255, 255, 255);
                                                    },
                                                  ),
                                                  side: MaterialStateProperty
                                                      .resolveWith<BorderSide>(
                                                    (Set<MaterialState>
                                                        states) {
                                                      if (states.contains(
                                                          MaterialState
                                                              .pressed)) {
                                                        return BorderSide(
                                                            color: Colors.green,
                                                            width: 2.0);
                                                      }
                                                      return BorderSide(
                                                          color: Colors.green,
                                                          width: 2.0);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Format payment method function to map abbreviation to full name
  String _formatPaymentMethod(String abbreviation) {
    return paymentMethodMap[abbreviation] ?? abbreviation;
  }

  String _formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }
}

class CountdownTimer extends StatefulWidget {
  final DateTime bookedAt;

  CountdownTimer({required this.bookedAt});

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  Duration _remainingTime = Duration();
  late DateTime _targetTime;

  @override
  void initState() {
    super.initState();
    _targetTime = widget.bookedAt.add(Duration(minutes: 20));
    _remainingTime = _targetTime.difference(DateTime.now());
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime = _targetTime.difference(DateTime.now());
        if (_remainingTime.isNegative) {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remainingTime.isNegative) {
      return Text(
        'Time is up!',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      );
    }

    return Text(
      '${_remainingTime.inMinutes.toString().padLeft(2, '0')}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
    );
  }
}
