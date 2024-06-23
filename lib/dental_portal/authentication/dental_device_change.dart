import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_dental.dart'; // Import the LoginDental screen

class DentalDeviceChange extends StatefulWidget {
  DentalDeviceChange();

  @override
  _DentalDeviceChangeState createState() => _DentalDeviceChangeState();
}

class _DentalDeviceChangeState extends State<DentalDeviceChange> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  Future<void> _submitRequest() async {
    final String email = _emailController.text;
    final String message = _messageController.text;

    _showLoadingIndicator();

    final response = await http.post(
      Uri.parse(
          'https://dental-key-738b90a4d87a.herokuapp.com/users/device-change-request/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'message': message,
        'status': 'pending',
      }),
    );

    Navigator.of(context).pop(); // Dismiss the loading indicator

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request submitted successfully!')),
      );
      _clearFields(); // Clear the fields after showing the snackbar
      _handleLogout(); // Log out and navigate to the login screen
    } else if (response.statusCode == 400) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData.containsKey('email')) {
        final String emailError = responseData['email'][0];
        _showDialog('Error', emailError);
      } else {
        _showDialog('Error', 'Failed to submit request');
      }
    } else {
      _showDialog('Error', 'Failed to submit request');
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('refreshToken');

    if (refreshToken != null) {
      try {
        final response = await http.post(
          Uri.parse(
              'https://dental-key-738b90a4d87a.herokuapp.com/users/logout/'),
          body: json.encode({'refresh_token': refreshToken}),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${prefs.getString('accessToken')}',
          },
        );

        if (response.statusCode == 205) {
          // Successfully logged out, remove tokens from local storage
          await prefs.remove('accessToken');
          await prefs.remove('refreshToken');

          // Navigate to the login screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginDental()),
          );
        } else {
          // Handle unsuccessful logout attempt
          final Map<String, dynamic> responseData = json.decode(response.body);
          String errorMessage =
              responseData['error'] ?? 'Logout failed. Please try again.';

          // Display error message
          _showDialog('Error', errorMessage);
        }
      } catch (e) {
        // Handle error during logout process
        _showDialog('Error', 'An error occurred. Please try again later.');
      }
    } else {
      // No refresh token found, just clear access token and navigate to login
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');

      // Navigate to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginDental()),
      );
    }
  }

  void _showLoadingIndicator() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void _showDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _clearFields() {
    _emailController.clear();
    _messageController.clear();
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginDental(),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    // Redirect to DentalPortalMain when back button is pressed
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginDental()),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dental Device Change Request'),
          automaticallyImplyLeading: false, // Hides the back button
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.3, // Set the desired transparency level here
                child: Image.asset(
                  'assets/images/device_change.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 18, left: 18, top: 50),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                            .hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      controller: _messageController,
                      decoration: InputDecoration(labelText: 'Message'),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your message';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _submitRequest();
                        }
                      },
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
