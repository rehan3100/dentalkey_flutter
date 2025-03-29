import 'dart:convert';
import 'package:dental_key/passwordforgotten_dental.dart';
import 'package:dental_key/patient_portal/mainscreen/familymemberslist.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dental_key/patient_portal/authentication/signup_patient.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'email_verification_screen.dart';

class LoginPatient extends StatefulWidget {
  @override
  _LoginPatientState createState() => _LoginPatientState();
}

class _LoginPatientState extends State<LoginPatient> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Please enter both email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/patients_dental/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print("API Response Status: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print("Response Data: $responseData");

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', responseData['access']);
        await prefs.setString('refreshToken', responseData['refresh']);

        // Store the patient ID (or UUID) if available
        if (responseData.containsKey('user') &&
            responseData['user'].containsKey('uuid')) {
          final userUuid = responseData['user']['uuid'];
          await prefs.setString('patientUuid', userUuid);
          print("Patient UUID: $userUuid");
        }

        // Ensure the patient ID is fetched and used
        final patientId =
            responseData['user']['uuid']; // patient_id from login API

        // Save patient_id to use in profile fetch
        await prefs.setString('patientId', patientId);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => DependentsListPage(patientId: patientId)),
        );
      } else if (response.statusCode == 403 &&
          json.decode(response.body)['requires_verification'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EmailVerificationScreen(email: email, isFromLogin: true),
          ),
        );
      } else {
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        _showErrorDialog(
            errorResponse['error'] ?? 'An unexpected error occurred.');
      }
    } catch (e) {
      _showErrorDialog('A network error occurred. Please try again later.');
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
        title: Text('Login Failed'),
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

  void _launchPrivacyPolicy() async {
    const url =
        'https://www.freeprivacypolicy.com/live/3f3fd527-1911-4727-b224-cbe260917b59';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Login'),
        backgroundColor: Color(0xff385a92),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'LOGIN',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff385a92),
                ),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: TextStyle(color: Color(0xff385a92)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: Color(0xff385a92),
                      width: 2.0,
                    ),
                  ),
                  prefixIcon: Icon(Icons.email, color: Color(0xff385a92)),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Color(0xff385a92)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: Color(0xff385a92),
                      width: 2.0,
                    ),
                  ),
                  prefixIcon: Icon(Icons.lock, color: Color(0xff385a92)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Color(0xff385a92),
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_passwordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PatientSignup()),
                      );
                    },
                    child: Text(
                      'No Account? Signup Now',
                      style: TextStyle(
                        color: Color(0xFF385A92),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DentalPasswordForgot()),
                      );
                    },
                    child: Text(
                      'Forgotten Password?',
                      style: TextStyle(
                        color: Color(0xFF385A92),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Login Now'),
                ),
              ),
              SizedBox(height: 20.0),
              GestureDetector(
                onTap: _launchPrivacyPolicy,
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
