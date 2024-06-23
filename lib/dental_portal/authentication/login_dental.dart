import 'dart:convert';
import 'package:dental_key/dental_portal/authentication/dental_device_change.dart';
import 'package:dental_key/dental_portal/mainscreen/dentalportal_main.dart';
import 'package:dental_key/main_screen.dart';
import 'package:dental_key/passwordforgotten_dental.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dental_key/dental_portal/authentication/signup_dental.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'dart:io' show Platform;
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:advertising_id/advertising_id.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginDental extends StatefulWidget {
  @override
  _LoginDentalState createState() => _LoginDentalState();
}

class _LoginDentalState extends State<LoginDental> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;

  static const screenshotplatform = MethodChannel('com.dentalkeybydrrehan.dentalkey/screenshot');

  @override
  void initState() {
    super.initState();
    _enableScreenshotRestriction();
    getSecureVendorIdentifier();
  }

  Future<void> _enableScreenshotRestriction() async {
    if (Platform.isAndroid) {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  @override
  void dispose() {
    _disableScreenshotRestriction();
    super.dispose();
  }

  Future<void> _disableScreenshotRestriction() async {
    if (Platform.isAndroid) {
      await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  static const platform = MethodChannel('com.dentalkeybydrrehan.dentalkey/device_id');

  Future<Map<String, String?>> _getDeviceIdentifiers() async {
    String? androidId;
    String? advertisingId;

    try {
      if (Platform.isAndroid) {
        androidId = await platform.invokeMethod('getAndroidId');
        advertisingId = await platform.invokeMethod('getAdvertisingId');
      } else if (Platform.isIOS) {
        androidId = await getKeychainIdentifier();
        advertisingId = await getSecureVendorIdentifier();

      }
    } on PlatformException catch (e) {
      print('Failed to get device identifiers: ${e.message}');
    }

    return {
      'androidId': androidId,
      'advertisingId': advertisingId,
    };
  }

  Future<String?> getSecureVendorIdentifier() async {
    try {
      return await platform.invokeMethod('getSecureVendorIdentifier');
    } on PlatformException catch (e) {
      print('Failed to get secure vendor identifier: ${e.message}');
      return null;
    }
  }


  Future<String> getKeychainIdentifier() async {
    final storage = FlutterSecureStorage();
    final uuid = Uuid();

    String? deviceIdentifier = await storage.read(key: 'device_identifier');
    
    if (deviceIdentifier == null) {
      deviceIdentifier = uuid.v4();
      await storage.write(key: 'device_identifier', value: deviceIdentifier);
    }

    return deviceIdentifier;
  }

  Future<void> _handleLogin() async {

    final email = _emailController.text;
    final password = _passwordController.text;


    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, String?> deviceIdentifiers = await _getDeviceIdentifiers();
      String? deviceIdentifier = deviceIdentifiers['androidId'];
      String? advertisingId = deviceIdentifiers['advertisingId'];

      if (deviceIdentifier == null) {
        throw Exception('Failed to get device identifier');
      }
      print('Device Identifier (Android ID): $deviceIdentifier');
      print('Advertising ID: $advertisingId');

      final response = await http.post(
        Uri.parse('https://dental-key-738b90a4d87a.herokuapp.com/users/login/'),
        body: {
          'email': email,
          'password': password,
          'device_identifier': deviceIdentifier,
          'advertising_id': advertisingId,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        String accessToken = responseData['access'];
        String refreshToken = responseData['refresh'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
        await prefs.setString('refreshToken', refreshToken);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DentalPortalMain(
              accessToken: accessToken,
            ),
          ),
        );
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        String errorMessage =
            responseData['error'] ?? 'An error occurred. Please try again.';

        print('Error Message: $errorMessage');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Login Failed'),
            content: Text(errorMessage),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Exception: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred. Please try again later.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
              ),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('refreshToken');

    if (refreshToken != null) {
      final response = await http.post(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/api/token/refresh/'),
        body: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        String newAccessToken = responseData['access'];

        // Store the new access token
        await prefs.setString('accessToken', newAccessToken);
      } else {
        // Handle token refresh error
        await prefs.remove('accessToken');
        await prefs.remove('refreshToken');
        // Redirect to login screen
      }
    } else {
      // Handle missing refresh token case
    }
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
    return false;
  }

  void _launchPrivacyPolicy() async {
    const url = 'https://www.freeprivacypolicy.com/live/3f3fd527-1911-4727-b224-cbe260917b59';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    double fem = 1.0; // Placeholder value for fem
    double ffem = 1.0; // Placeholder value for ffem

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dentist Portal'),
          backgroundColor: Color(0xff385a92),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.0 * fem),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'LOGIN',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 30 * ffem,
                    fontWeight: FontWeight.w600,
                    height: 1.2125 * ffem / fem,
                    letterSpacing: -0.45 * fem,
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
                    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
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
                              builder: (context) => DentalSignup()),
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
                    onPressed: _handleLogin,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Text(
                          'Login Now',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_isLoading)
                          const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DentalDeviceChange()),
                      );
                    },
                    child: const Text(
                      'Request Change In Device',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0), // Add some space before the new section
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
      ),
    );
  }
}