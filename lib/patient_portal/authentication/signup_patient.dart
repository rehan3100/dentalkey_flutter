import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:intl/intl.dart'; // For date formatting
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'email_verification_signup.dart'; // Import the email verification screen

class PatientSignup extends StatefulWidget {
  @override
  _PatientSignupState createState() => _PatientSignupState();
}

class EmailValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}

class PasswordValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    } else if (!RegExp(r'.*[A-Z].*').hasMatch(value)) {
      return 'At least one uppercase letter';
    } else if (!RegExp(r'.*[a-z].*').hasMatch(value)) {
      return 'At least one lowercase letter';
    } else if (!RegExp(r'.*[0-9].*').hasMatch(value)) {
      return 'At least one digit';
    } else if (!RegExp(r'.*[!@#\$&*~].*').hasMatch(value)) {
      return 'At least one special character';
    }
    return null;
  }
}

class _PatientSignupState extends State<PatientSignup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  String _phoneNumber = '';
  TextEditingController _dateOfBirthController =
      TextEditingController(); // New Controller for DOB

  Future<void> _signupPatientUser() async {
    const String apiUrl =
        'https://dental-key-738b90a4d87a.herokuapp.com/patients_dental/signup/';

    // Prepare data for patient signup
    final Map<String, dynamic> payload = {
      "full_name": _fullNameController.text,
      "email": _emailController.text,
      "phone_number": _phoneNumber,
      "password": _passwordController.text,
      "date_of_birth": _dateOfBirthController.text, // Send DOB here
    };

    try {
      print("Starting API call to $apiUrl with payload: $payload");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      print("API response received with status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("Signup successful: ${data['message']}");

        // Capture and store patient_id from the response
        if (data.containsKey('patient_details') &&
            data['patient_details'].containsKey('id')) {
          String patientUuid = data['patient_details']['id'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('patient_id', patientUuid); // Store the UUID
          print("Patient UUID stored in Shared Preferences: $patientUuid");

          // Proceed with redirect or other operations
        } else {
          print("Patient UUID not returned in the response.");
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Signup successful. Please verify your email.")),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EmailVerificationSignUpScreen(email: _emailController.text),
          ),
        );
      } else {
        final error =
            response.headers['content-type']?.contains('application/json') ??
                    false
                ? jsonDecode(response.body)
                : response.body;
        print("Signup failed: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup failed: $error")),
        );
      }
    } catch (error) {
      print("An error occurred during signup: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Signup'),
        backgroundColor: Color(0xff385a92),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'SIGN UP',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff385a92),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: EmailValidator.validate,
                ),
                SizedBox(height: 20.0),
                InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    _phoneNumber = number.phoneNumber ?? '';
                  },
                  selectorConfig: SelectorConfig(
                    selectorType: PhoneInputSelectorType.DIALOG,
                  ),
                  inputDecoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: PhoneNumber(isoCode: 'US'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (_phoneNumber.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: PasswordValidator.validate,
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    } else if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _dateOfBirthController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      _dateOfBirthController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your date of birth';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _signupPatientUser();
                    }
                  },
                  child: Text('Sign Up'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color(0xff385a92), // Updated property for button color
                  ),
                ),
                SizedBox(height: 20.0),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Navigate to Login screen
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: Color(0xff385a92)),
                        children: [
                          TextSpan(
                            text: 'Login Now',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff385a92),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
