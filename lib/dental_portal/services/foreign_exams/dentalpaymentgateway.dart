import 'package:flutter/material.dart';

class PaymentGatewayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Gateway'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Payment Method:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            // Payment method selection (Radio buttons or dropdown menu)
            // Implement according to your requirements

            // Payment details fields (Credit card, PayPal, Stripe, etc.)
            // Implement relevant fields based on selected payment method

            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Handle payment processing logic
                // Redirect to payment gateway or process payment here
              },
              child: Text('Pay Now'),
            ),
            SizedBox(height: 8.0),
            TextButton(
              onPressed: () {
                // Handle cancel button action
                Navigator.pop(context); // Navigate back to previous screen
              },
              child: Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
