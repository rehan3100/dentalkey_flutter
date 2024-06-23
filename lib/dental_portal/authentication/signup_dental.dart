import 'package:dental_key/dental_portal/authentication/login_dental.dart';
import 'package:dental_key/dental_portal/authentication/modal_signup_dental.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:flutter/gestures.dart';
import 'package:country_picker/country_picker.dart';
import 'dart:io';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

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

class DentalSignup extends StatefulWidget {
  @override
  _DentalSignupState createState() => _DentalSignupState();
}

class _DentalSignupState extends State<DentalSignup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _institutionController = TextEditingController();
  String _selectedGender = 'Male';
  String _selectedCurrentStatus = 'Undergraduate Dental Student';

  String _phoneNumber = '';
  String _selectedCountryCode = 'US';
  String? _emailError;
  String? _passwordError;
  String _whatsappNumber = '';
  String _selected2CountryCode = 'US';
  String _alternativeNumber = '';
  String _selected3CountryCode = 'US';
  String _selectedCurrentCountry = '';
  String _selectedGraduationCountry = '';
  String _degreeAwardingBody = '';
  List<int> years = List<int>.generate(25, (index) => index + 2006);
  int _selectedYear = DateTime.now().year;

  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _enableScreenshotRestriction(); // Add this line
  }

  Future<void> _enableScreenshotRestriction() async {
    if (Platform.isAndroid) {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  @override
  void dispose() {
    _disableScreenshotRestriction(); // Add this line

    super.dispose();
  }

  Future<void> _disableScreenshotRestriction() async {
    if (Platform.isAndroid) {
      await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text;
      final String password = _passwordController.text;
      final String fullName = _fullNameController.text;
      final String institution = _institutionController.text;
      final String phoneNumber = _phoneNumber;
      final String whatsappNumber = _whatsappNumber;
      final String alternativeNumber = _alternativeNumber;

      if (password != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Passwords don't match"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Map<String, dynamic> requestData = {
        'email': email,
        'password': password,
        'full_name': fullName,
        'gender': _selectedGender,
        'current_status': _selectedCurrentStatus,
        'phone_number': phoneNumber,
        'whatsapp_number': whatsappNumber,
        'alternative_contact_number': alternativeNumber,
        'institution_practice': institution,
        'degree_awarding_body': _degreeAwardingBody,
        'expected_year_of_graduation': _selectedYear,
        'current_country': _selectedCurrentCountry,
        'country_of_graduation': _selectedGraduationCountry,
      };

      // Show loader
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text("Signing up..."),
                ],
              ),
            ),
          );
        },
      );

      try {
        final response = await http.post(
          Uri.parse(
              'https://dental-key-738b90a4d87a.herokuapp.com/users/dental/signup/'),
          body: json.encode(requestData),
          headers: {'Content-Type': 'application/json'},
        );

        Navigator.of(context).pop(); // Hide loader

        if (response.statusCode == 201) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DentalProfileApproval(),
            ),
          );
        } else {
          final responseBody = json.decode(response.body);
          String errorMessage = 'Failed to signup. Please try again later.';

          print('Response body: ${response.body}');

          if (responseBody.containsKey('email')) {
            errorMessage = responseBody['email'][0];
          } else if (responseBody is Map &&
              responseBody.containsKey('non_field_errors')) {
            errorMessage = responseBody['non_field_errors'][0];
          }

          print('Signup failed with status: ${response.statusCode}');
          print('Error message: $errorMessage');

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Signup Failed"),
                content: Text(errorMessage),
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
        Navigator.of(context).pop(); // Hide loader
        print('Signup failed with error: $error');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Signup Failed"),
              content: Text("Failed to signup. Please try again later."),
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
  }

  @override
  Widget build(BuildContext context) {
    double fem = 1.0;
    double ffem = 1.0;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Container(
            padding: EdgeInsets.fromLTRB(0 * fem, 6 * fem, 0 * fem, 0 * fem),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xff5a5a5a)),
              color: Color(0xff385a92),
              borderRadius: BorderRadius.circular(45 * fem),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  color: Color(0xff385a92),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin:
                            EdgeInsets.fromLTRB(0 * fem, 20 * fem, 0 * fem, 5),
                        width: 150 * fem,
                        height: 200 * fem,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15 * fem),
                          child: Image.asset(
                            'assets/images/dentalportalclicked.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 0),
                  color: Color.fromARGB(255, 255, 255, 255),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            0 * fem, 20 * fem, 0 * fem, 0 * fem),
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 30 * ffem,
                            fontWeight: FontWeight.w600,
                            height: 1.2125 * ffem / fem,
                            letterSpacing: -0.45 * fem,
                            color: Color(0xff385a92),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            20 * fem, 0 * fem, 20 * fem, 20 * fem),
                        width: double.infinity,
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email Address',
                                    labelStyle:
                                        TextStyle(color: Color(0xff385a92)),
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
                                    prefixIcon: Icon(Icons.email,
                                        color: Color(0xff385a92)),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: EmailValidator.validate,
                                ),
                                if (_emailError != null)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      _emailError!,
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                SizedBox(height: 20.0),
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle:
                                        TextStyle(color: Color(0xff385a92)),
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
                                    prefixIcon: Icon(Icons.lock,
                                        color: Color(0xff385a92)),
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
                                  validator: PasswordValidator.validate,
                                ),
                                if (_passwordError != null)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      _passwordError!,
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                SizedBox(height: 20.0),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                    labelStyle:
                                        TextStyle(color: Color(0xff385a92)),
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
                                    prefixIcon: Icon(Icons.lock,
                                        color: Color(0xff385a92)),
                                  ),
                                  obscureText: !_passwordVisible,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    } else if (value !=
                                        _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20.0),
                                TextFormField(
                                  controller: _fullNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Full Name',
                                    labelStyle:
                                        TextStyle(color: Color(0xff385a92)),
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
                                    prefixIcon: Icon(Icons.person,
                                        color: Color(0xff385a92)),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your full name';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedGender,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedGender = value!;
                                          });
                                        },
                                        items: ['Male', 'Female', 'Other']
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        decoration: InputDecoration(
                                          labelText: 'Gender',
                                          labelStyle:
                                              TextStyle(color: Color(0xff385a92)),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: BorderSide(
                                              color: Color(0xff385a92),
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.help_outline,
                                          color: Color(0xff385a92)),
                                      onPressed: () {
                                        _showInfoDialog('Gender',
                                            'Please select your gender.');
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedCurrentStatus,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedCurrentStatus = value!;
                                          });
                                        },
                                        items: [
                                          'Undergraduate Dental Student',
                                          'General Dentist',
                                          'Postgraduate Dental Student',
                                          'Specialist Dentist'
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        decoration: InputDecoration(
                                          labelText: 'Your Current Status',
                                          labelStyle:
                                              TextStyle(color: Color(0xff385a92)),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: BorderSide(
                                              color: Color(0xff385a92),
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.help_outline,
                                          color: Color(0xff385a92)),
                                      onPressed: () {
                                        _showInfoDialog('Current Status',
                                            'This information is required to get exact information about your current status. You can later change this in your edit profile section of the account page. This will help us identify that you are the right user of the app or not.');
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.0),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InternationalPhoneNumberInput(
                                        onInputChanged: (PhoneNumber? number) {
                                          setState(() {
                                            _phoneNumber = number?.phoneNumber ?? '';
                                            _selectedCountryCode =
                                                number?.isoCode ?? 'US';
                                          });
                                        },
                                        selectorConfig: SelectorConfig(
                                          selectorType:
                                              PhoneInputSelectorType.BOTTOM_SHEET,
                                        ),
                                        autoValidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        inputDecoration: InputDecoration(
                                          labelText: 'Phone Number',
                                          labelStyle: TextStyle(
                                            color: Color(0xff385a92),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: BorderSide(
                                              color: Color(0xff385a92),
                                              width: 2.0,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0,
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 15.0, horizontal: 10.0),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.auto,
                                        ),
                                        initialValue: PhoneNumber(
                                            isoCode: _selectedCountryCode),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.help_outline,
                                          color: Color(0xff385a92)),
                                      onPressed: () {
                                        _showInfoDialog('Phone Number',
                                            'At least one phone number is required to create your account. In case you are unable to reply on email, we would like to contact you using phone number.');
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.0),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InternationalPhoneNumberInput(
                                        onInputChanged: (PhoneNumber? number) {
                                          setState(() {
                                            _whatsappNumber =
                                                number?.phoneNumber ?? '';
                                            _selected2CountryCode =
                                                number?.isoCode ?? 'US';
                                          });
                                        },
                                        selectorConfig: SelectorConfig(
                                          selectorType:
                                              PhoneInputSelectorType.BOTTOM_SHEET,
                                        ),
                                        autoValidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        inputDecoration: InputDecoration(
                                          labelText: 'WhatsApp Number',
                                          labelStyle: TextStyle(
                                            color: Color(0xff385a92),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: BorderSide(
                                              color: Color(0xff385a92),
                                              width: 2.0,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0,
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 15.0, horizontal: 10.0),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.auto,
                                        ),
                                        initialValue: PhoneNumber(
                                            isoCode: _selected2CountryCode),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.help_outline,
                                          color: Color(0xff385a92)),
                                      onPressed: () {
                                        _showInfoDialog('WhatsApp Number',
                                            'This is mandatory as part of your verification process that you are really a dental student or dentist. On WhatsApp, you will only be receiving a text message from "+923078623100" or "+447956646619". You will be requested to provide your eligibility documents on either WhatsApp or email to dentalkey.rehan@gmail.com.');
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.0),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InternationalPhoneNumberInput(
                                        onInputChanged: (PhoneNumber? number) {
                                          setState(() {
                                            _alternativeNumber =
                                                number?.phoneNumber ?? '';
                                            _selected3CountryCode =
                                                number?.isoCode ?? 'US';
                                          });
                                        },
                                        selectorConfig: SelectorConfig(
                                          selectorType:
                                              PhoneInputSelectorType.BOTTOM_SHEET,
                                        ),
                                        autoValidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        inputDecoration: InputDecoration(
                                          labelText:
                                              'Alternative Contact Number',
                                          labelStyle: TextStyle(
                                            color: Color(0xff385a92),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: BorderSide(
                                              color: Color(0xff385a92),
                                              width: 2.0,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0,
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 15.0, horizontal: 10.0),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.auto,
                                        ),
                                        initialValue: PhoneNumber(
                                            isoCode: _selected3CountryCode),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.help_outline,
                                          color: Color(0xff385a92)),
                                      onPressed: () {
                                        _showInfoDialog(
                                            'Alternative Contact Number',
                                            'You can provide any alternative contact number, if you do not have any you can either write phone number or WhatsApp contact number in place of alternative contact number.');
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.0),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _institutionController,
                                        decoration: InputDecoration(
                                          labelText:
                                              'Institution/Practice Name',
                                          labelStyle:
                                              TextStyle(color: Color(0xff385a92)),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: BorderSide(
                                              color: Color(0xff385a92),
                                              width: 2.0,
                                            ),
                                          ),
                                          prefixIcon: Icon(Icons.school,
                                              color: Color(0xff385a92)),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your institution';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.help_outline,
                                          color: Color(0xff385a92)),
                                      onPressed: () {
                                        _showInfoDialog('Institution or Practice Name',
                                            'It will help us identifying that all the information you have given is matching with your eligibility documents or not. If you shift your practice or institute, please update it in your profile edit section.');
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                GestureDetector(
                                  onTap: () {
                                    _showCountryPickerDialog(true);
                                  },
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      controller: TextEditingController(
                                          text: _selectedCurrentCountry),
                                      decoration: InputDecoration(
                                        labelText:
                                            _selectedCurrentCountry.isEmpty
                                                ? 'Select Current Country'
                                                : 'Selected Current Country',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 12.0),
                                        suffixIcon: Icon(Icons.arrow_drop_down),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                GestureDetector(
                                  onTap: () {
                                    _showCountryPickerDialog(false);
                                  },
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      controller: TextEditingController(
                                          text: _selectedGraduationCountry),
                                      decoration: InputDecoration(
                                        labelText: _selectedGraduationCountry
                                                .isEmpty
                                            ? 'Select Country of Graduation'
                                            : 'Selected Country of Graduation',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 12.0),
                                        suffixIcon: Icon(Icons.arrow_drop_down),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                DropdownButtonFormField<int>(
                                  value: _selectedYear,
                                  onChanged: (int? newValue) {
                                    setState(() {
                                      _selectedYear = newValue!;
                                    });
                                  },
                                  items: years
                                      .map<DropdownMenuItem<int>>((int value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(value.toString()),
                                    );
                                  }).toList(),
                                  decoration: InputDecoration(
                                    labelText: 'Graduation Year',
                                    labelStyle:
                                        TextStyle(color: Color(0xff385a92)),
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
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Degree Awarding Body',
                                    labelStyle:
                                        TextStyle(color: Color(0xff385a92)),
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
                                    prefixIcon: Icon(Icons.school,
                                        color: Color(0xff385a92)),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _degreeAwardingBody = value;
                                    });
                                  },
                                ),
                                SizedBox(height: 20.0),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _handleSignup,
                                    child: Text(
                                      'Sign Up',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Color(0xff385a92)),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginDental()),
                                      );
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'Already have an account? ',
                                        style:
                                            TextStyle(color: Color(0xff385a92)),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: 'Login Now',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff385a92),
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          LoginDental()),
                                                );
                                              },
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCountryPickerDialog(bool isCurrentCountry) {
    showCountryPicker(
      context: context,
      onSelect: (Country country) {
        setState(() {
          if (isCurrentCountry) {
            _selectedCurrentCountry = country.name;
          } else {
            _selectedGraduationCountry = country.name;
          }
        });
      },
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
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
