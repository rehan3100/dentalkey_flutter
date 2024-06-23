import 'package:confetti/confetti.dart';
import 'package:dental_key/dental_portal/services/career_pathways/CP_dental_my_orders.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

class CpCartPage extends StatefulWidget {
  final String accessToken;
  final List<Map<String, dynamic>> cartItems;
  final String countryName;

  CpCartPage({
    required this.accessToken,
    required this.cartItems,
    required this.countryName,
  });

  @override
  _CpCartPageState createState() => _CpCartPageState();
}

class _CpCartPageState extends State<CpCartPage> {
  double totalPrice = 0;
  late String _selectedPaymentMethodCode = '';
  late String _selectedPaymentMethodName = '';
  late String userUUID;
  bool _isCheckingOut = false; // Variable to track checkout action

  @override
  void initState() {
    super.initState();
    calculateTotalPrice();
    getUserUUID();
  }

  void calculateTotalPrice() {
    double total = 0;
    for (var item in widget.cartItems) {
      total += item['price'] ?? 0;
    }
    setState(() {
      totalPrice = total;
    });
  }

  Future<void> getUserUUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userUUID = prefs.getString('userUUID') ?? '';
    });
  }

  Future<List<Map<String, dynamic>>> _fetchPaymentMethods() async {
    final response = await http.get(
      Uri.parse(
          'https://dental-key-738b90a4d87a.herokuapp.com/career_pathways/payment-methods/'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
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
                      _selectedPaymentMethodCode = method['code'];
                      _selectedPaymentMethodName = method['name'];
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

    // Decode the JWT token
    Map<String, dynamic> payload = Jwt.parseJwt(widget.accessToken);

    // Debug: Print the decoded payload
    print('Decoded JWT payload: $payload');

    // Access the decoded token's data
    String? userUUID = payload['user_id']; // Adjust key to 'user_id'

    if (userUUID == null) {
      // Handle case when userUUID is not available
      print('User UUID is not available in the JWT token');
      // You might want to show an error message or prompt the user to log in again
      return;
    }

    print('User UUID from JWT: $userUUID');

    // Prepare other data for the request
    List<String> selectedPackageIds = [];
    for (var item in widget.cartItems) {
      // Ensure that the package_id is correctly assigned
      String? packageId = item['package_id']; // Check if this key is correct
      if (packageId != null && packageId.isNotEmpty) {
        selectedPackageIds.add(packageId);
      }
    }

    // Debug: Print selected package IDs
    print('Selected Package IDs: $selectedPackageIds');

    // Prepare the request body
    Map<String, dynamic> requestBody = {
      'user': userUUID,
      'package_payment_method': _selectedPaymentMethodCode ?? 'OB',
      'selected_packages': selectedPackageIds,
      'package_order_total_price': totalPrice.toStringAsFixed(2),
      'package_ordered_currency':
          widget.cartItems.isNotEmpty ? widget.cartItems.last['currency'] : '',
      'country': widget.cartItems.last['country'],
    };

    // Debug: Print the request body
    print('Request body: $requestBody');

    // Send the request
    final response = await http.post(
      Uri.parse(
          'https://dental-key-738b90a4d87a.herokuapp.com/career_pathways/package-orders/'),
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CPConfirmationPage(
            accessToken: widget.accessToken,
            currency: widget.cartItems.isNotEmpty
                ? widget.cartItems.last['currency']
                : '', // Pass currency here
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
        title: Text('Cart Page'),
      ),
      body: Stack(
        children: [
          // Background image with transparency
          Opacity(
            opacity: 0.2, // Set the desired opacity here
            child: Align(
              alignment: Alignment
                  .center, // Custom alignment between bottom and center
              child: Image.asset(
                'assets/images/cart_back.png',
                width: 300, // Set the desired width
                height: 300, // Set the desired height
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 10.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      var item = widget.cartItems[index];
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(
                            item['name'],
                            style: TextStyle(fontSize: 16.0),
                          ),
                          subtitle: Text(
                            '${item['currency']} ${item['price']}',
                            style: TextStyle(fontSize: 14.0),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(height: 10.0),
                      if (_selectedPaymentMethodCode != null)
                        Center(
                          child: Text(
                            'Selected: $_selectedPaymentMethodName',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      SizedBox(height: 10.0),
                      Center(
                        child: Text(
                          'Total Price: ${widget.cartItems.isNotEmpty ? widget.cartItems.last['currency'] : ''} ${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showPaymentMethods(context),
                          child: Text('Select Payment Method'),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      if (_selectedPaymentMethodCode != null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isCheckingOut
                                ? null
                                : () {
                                    // Calculate requestedTotalPrice here before passing to _handleCheckout
                                    _handleCheckout(context);
                                  },
                            child: _isCheckingOut
                                ? CircularProgressIndicator()
                                : Text('Checkout'),
                          ),
                        ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CPConfirmationPage extends StatefulWidget {
  final String accessToken;
  final String currency;

  CPConfirmationPage({
    required this.accessToken,
    required this.currency,
  });

  @override
  _CPConfirmationPageState createState() => _CPConfirmationPageState();
}

class _CPConfirmationPageState extends State<CPConfirmationPage> {
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
                              CPDentalMyOrders(accessToken: widget.accessToken),
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
