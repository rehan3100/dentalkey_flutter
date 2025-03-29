import 'dart:convert';
import 'package:dental_key/patient_portal/mainscreen/familymemberslist.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_patient.dart'; // Import Login screen for redirect after verification
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class EmailVerificationSignUpScreen extends StatefulWidget {
  final String email; // The user's email
  final bool isFromLogin; // True if coming from login flow

  EmailVerificationSignUpScreen(
      {required this.email, this.isFromLogin = false});

  @override
  _EmailVerificationSignUpScreenState createState() =>
      _EmailVerificationSignUpScreenState();
}

class _EmailVerificationSignUpScreenState
    extends State<EmailVerificationSignUpScreen> {
  TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  // Remove the automatic call to `_sendVerificationCode()` in `initState()`
  @override
  void initState() {
    super.initState();
  }

  Future<void> _sendVerificationCode() async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/patients_dental/resend-verification-code/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {'email': widget.email}), // Sending email, not patient_id
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification code resent to your email.")),
        );
      } else {
        final errorMessage = json.decode(response.body)['error'] ??
            'Failed to resend verification code.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      // Retrieve the patient UUID from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String patientUuid =
          prefs.getString('patient_id') ?? ''; // Use patient_uuid

      // Ensure that the patient UUID is available before proceeding
      if (patientUuid.isEmpty) {
        _showErrorDialog('Patient UUID not found. Please sign up first.');
        return;
      }

      print("Patient UUID: $patientUuid"); // Debugging

      final response = await http.post(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/patients_dental/verify-email-code/'),
        body: jsonEncode({
          'patient_id': patientUuid, // Send patient_uuid as patient_id
          'code': code
        }),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Email verified successfully.")),
        );

        if (widget.isFromLogin) {
          // After successful email verification, retrieve patientId from SharedPreferences
          String patientId = prefs.getString('patient_id') ??
              ''; // Get patientId from preferences

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => DependentsListPage(patientId: patientId)),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPatient()),
            (route) => false,
          );
        }
      } else {
        final errorMessage = json.decode(response.body)['error'] ??
            'Invalid verification code. Please try again.';
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      _showErrorDialog('An error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Email Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'A verification code has been sent to your email.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Verification Code',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyCode,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Verify Code'),
            ),
            TextButton(
              onPressed:
                  _sendVerificationCode, // Trigger resend on button press
              child: Text('Resend Code'),
            ),
          ],
        ),
      ),
    );
  }
}
