import 'package:confetti/confetti.dart';
import 'package:dental_key/dental_portal/services/foreign_exams/FE_my_orders.dart';
import 'package:flutter/material.dart';
import 'package:dental_key/dental_portal/services/foreign_exams/foreign_mockexams.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

class ForeignExamsCartPage extends StatefulWidget {
  final String accessToken;
  final FECart fecart;
  final String quizCategoryUUID;
  ForeignExamsCartPage({
    required this.fecart,
    required this.accessToken,
    required this.quizCategoryUUID,
  });

  @override
  _ForeignExamsCartPageState createState() => _ForeignExamsCartPageState();
}

class _ForeignExamsCartPageState extends State<ForeignExamsCartPage> {
  double requestedTotalPrice = 0;
  late String _selectedPaymentMethod = '';
  late String userUUID;
  bool _isCheckingOut = false; // Variable to track checkout action

  void _calculaterequestedTotalPrice() {
    double total = 0;
    for (var item in widget.fecart.items) {
      // Extract numerical part of the price string
      String numericalPrice = item.price.replaceAll(RegExp(r'[^0-9.]'), '');
      // Parse numerical price into double
      total += double.parse(numericalPrice);
    }
    setState(() {
      requestedTotalPrice = total;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserUUID();
    _calculaterequestedTotalPrice(); // Calculate total price when the page is initialized
  }

  @override
  void didUpdateWidget(covariant ForeignExamsCartPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _calculaterequestedTotalPrice(); // Recalculate total price when the widget is updated
  }

  Future<void> getUserUUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userUUID = prefs.getString('userUUID') ?? '';
    });
  }

  Future<List<dynamic>> _fetchPaymentMethods() async {
    final response = await http.get(
      Uri.parse(
          'https://dental-key-738b90a4d87a.herokuapp.com/quizzer/payment-methods/'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load payment methods');
    }
  }

  Future<void> _showPaymentMethods(BuildContext context) async {
    final paymentMethods = await _fetchPaymentMethods();

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
              SizedBox(height: 10), // Add some spacing
              for (var method in paymentMethods)
                ListTile(
                  title: Text(method['name']),
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = method['code'];
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

  void _handleCheckout(BuildContext context) async {
    setState(() {
      _isCheckingOut = true; // Start the checkout action
    });

    Map<String, dynamic> payload = Jwt.parseJwt(widget.accessToken);

    String? userUUID = payload['user_id']; // Adjust key to 'user_id'

    if (userUUID == null) {
      print('User UUID is not available in the JWT token');
      return;
    }
    print('User UUID from JWT: $userUUID');
    print('Cart items: ${widget.fecart.items}');
    List<String> quizUUIDs =
        widget.fecart.items.map((item) => item.quizUUID).toList();
    print('Quiz IDs: $quizUUIDs'); // Debug: Print quizUUIDs

    Map<String, dynamic> requestBody = {
      'user': userUUID,
      'payment_method': _selectedPaymentMethod,
      'selected_quiz': quizUUIDs,
      'request_total_price': requestedTotalPrice.toStringAsFixed(2),
    };

    // Add quiz_category only if it's not null
    if (widget.quizCategoryUUID != null) {
      requestBody['quiz_category'] = widget.quizCategoryUUID.toString();
    }

    print('Request body: $requestBody');

    final response = await http.post(
      Uri.parse(
          'https://dental-key-738b90a4d87a.herokuapp.com/quizzer/request-quiz/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.accessToken}',
      },
      body: json.encode(requestBody),
    );

    // Debug: Print response status code and body
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    // Handle the response
    if (response.statusCode == 201) {
      // If the order is successfully created, navigate to confirmation page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FEConfirmationPage(
            accessToken: widget.accessToken,
            currency: 'GBP', // Pass currency here if needed
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to create order. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
    setState(() {
      _isCheckingOut = false; // Complete the checkout action
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
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/cart_back.png',
              width: 300, // Set the desired width
              height: 300, // Set the desired height
            ),
          ),
        ),
        widget.fecart.items.isNotEmpty
            ? ListView.builder(
                itemCount: widget.fecart.items.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 4,
                      child: ListTile(
                        leading: Image.network(
                          widget.fecart.items[index].quizImage,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          widget.fecart.items[index].title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          widget.fecart.items[index].price,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text('Your cart is empty.'),
              ),
      ]),
      bottomNavigationBar: requestedTotalPrice > 0.0
          ? Container(
              padding: EdgeInsets.all(10.0),
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
                  SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: () => _showPaymentMethods(context),
                    child: Text('Select Payment Method'),
                  ),
                  SizedBox(height: 10.0),
                  if (_selectedPaymentMethod != null)
                    ElevatedButton(
                      onPressed: () => _handleCheckout(context),
                      child: Text('Checkout'),
                    ),
                ],
              ),
            )
          : SizedBox(),
    );
  }
}

class FEConfirmationPage extends StatefulWidget {
  final String accessToken;
  final String currency;

  FEConfirmationPage({
    required this.accessToken,
    required this.currency,
  });

  @override
  _FEConfirmationPageState createState() => _FEConfirmationPageState();
}

class _FEConfirmationPageState extends State<FEConfirmationPage> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play(); // Play the confetti animation
  }

  @override
  void dispose() {
    _confettiController.dispose(); // Dispose the controller when not needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Order Confirmation'),
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 100,
                    color: Colors.green,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Your order has been placed successfully!',
                    textAlign: TextAlign.center, // Add this line
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ForeignOrders(accessToken: widget.accessToken),
                        ),
                      );
                    },
                    child: Text('Go to My Orders'),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false, // Do not loop
                colors: [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.yellow
                ], // Specify the colors for the confetti
              ),
            ),
          ],
        ),
      ),
    );
  }
}
