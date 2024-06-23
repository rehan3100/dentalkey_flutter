import 'package:confetti/confetti.dart';
import 'package:dental_key/dental_portal/services/ips_books/dental_my_orders.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'IPS_Books.dart';

class CartPage extends StatefulWidget {
  final Cart cart;

  CartPage({required this.cart});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late String _selectedPaymentMethod = ''; // Initialize with an empty string

  Future<List<dynamic>> _fetchPaymentMethods() async {
    final response = await http.get(
      Uri.parse(
          'https://dental-key-738b90a4d87a.herokuapp.com/ips/payment-methods/'),
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
                    // Handle payment method selection
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

  Future<void> _handleCheckout(BuildContext context) async {
    if (_selectedPaymentMethod == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Payment Method Not Selected"),
            content: Text("Please select a payment method."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      Map<String, dynamic> payload = Jwt.parseJwt(accessToken!);
      String userUUID = payload['user_id'];

      final totalPrice = widget.cart.items
          .fold(0.0, (sum, item) => sum + double.parse(item.price));

      Map<String, dynamic> requestData = {
        'user': userUUID,
        'payment_method':
            _selectedPaymentMethod ?? 'OB', // Use selected or default method
        'selected_books':
            widget.cart.items.map((item) => item.book_id).toList(),
        'order_total_price': totalPrice.toStringAsFixed(2),
      };

      final response = await http.post(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/ips/create-order/'),
        body: json.encode(requestData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        // Clear the cart after successful order submission
        await prefs.remove('cart'); // Assuming 'cart' is used as the key
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConfirmationPage(accessToken: accessToken)),
        );
      } else {
        print('Order failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Order Status Failed"),
              content: Text(
                  "Either your cart is Empty or you have not selected payment method"),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      print('Order failed with error: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Order Failed"),
            content: Text("Something Went Wrong"),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.cart.items
        .fold(0.0, (sum, item) => sum + double.parse(item.price));

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
        widget.cart.items.isNotEmpty
            ? ListView.builder(
                itemCount: widget.cart.items.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 4,
                      child: ListTile(
                        leading: Image.network(
                          widget.cart.items[index].cover_image,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          widget.cart.items[index].book_name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Price: GBP ${widget.cart.items[index].price}',
                          style: TextStyle(fontSize: 14),
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
      bottomNavigationBar: totalPrice > 0.0
          ? Container(
              padding: EdgeInsets.all(10.0),
              color: Colors.grey[200],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Total Price: \GBP ${totalPrice.toStringAsFixed(2)}',
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

class ConfirmationPage extends StatefulWidget {
  final String accessToken;

  ConfirmationPage({
    required this.accessToken,
  });

  @override
  _ConfirmationPageState createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
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
                              DentalMyOrders(accessToken: widget.accessToken),
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
