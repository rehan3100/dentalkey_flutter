import 'package:dental_key/marketplace/practices_network/practice_management.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OwnerLoginScreen extends StatefulWidget {
  @override
  _OwnerLoginScreenState createState() => _OwnerLoginScreenState();
}

class _OwnerLoginScreenState extends State<OwnerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController uuidController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool isLoading = false;
  bool isOtpSent = false;
  String errorMessage = '';
  String registrationStatus = ''; // Store registration status
  String explanation = ''; // Store explanation (if exists)
  String ownerId = ''; // Store UUID after first verification

  Future<void> loginOwner() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
      registrationStatus = '';
      explanation = '';
    });

    final url = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/login/");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "uuid": uuidController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      final responseData = jsonDecode(response.body);
      print("🔍 Response Status Code: ${response.statusCode}");
      print("🔍 Response Body: ${response.body}");

      setState(() {
        registrationStatus = responseData["registration_status"] ?? "Unknown";
        explanation = responseData["explanation"] ?? "";
        ownerId = responseData["uuid"] ?? "";
      });

      if (response.statusCode == 200) {
        setState(() {
          isOtpSent = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("OTP Sent! Please check your email."),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          errorMessage = responseData["error"] ?? "Login failed. Try again!";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Network error. Please try again!";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> verifyOTP() async {
    if (otpController.text.isEmpty) {
      setState(() {
        errorMessage = "Please enter OTP.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final url = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/verify-login-otp/");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "uuid": ownerId,
          "email": emailController.text.trim(),
          "otp_code": otpController.text.trim(),
        }),
      );

      final responseData = jsonDecode(response.body);
      print("🔍 Response Status Code: ${response.statusCode}");
      print("🔍 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login Successful!"),
            backgroundColor: Colors.green,
          ),
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('owner_email', emailController.text.trim());
        await prefs.setString('owner_uuid', ownerId);

        // ✅ Redirect to Practice Management Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => PracticeManagementScreen(ownerId: ownerId)),
        );
      } else {
        setState(() {
          errorMessage = responseData["error"] ?? "Invalid OTP!";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Network error. Please try again!";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset('assets/logo.png', width: 120, height: 120),
                  SizedBox(height: 10),
                  Text("Login as Practice Owner",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),

                  // ✅ Show Registration Status
                  if (registrationStatus.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: registrationStatus == "Approved"
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "Status: $registrationStatus",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    ),
                  SizedBox(height: 10),

                  if (!isOtpSent) ...[
                    TextFormField(
                      controller: uuidController,
                      decoration: InputDecoration(
                        labelText: "UUID",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "UUID is required" : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email Address",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) =>
                          value!.isEmpty ? "Password is required" : null,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: loginOwner,
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Login"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ] else ...[
                    TextFormField(
                      controller: otpController,
                      decoration: InputDecoration(
                        labelText: "Enter OTP",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? "OTP is required" : null,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: verifyOTP,
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Verify OTP"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],

                  // ✅ Show Explanation Below Status (If exists)
// ✅ Show Explanation Below Status (ONLY if NOT Approved)
                  if (registrationStatus.isNotEmpty &&
                      registrationStatus != "Approved" &&
                      explanation.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "$explanation",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),

                  SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to Forgot Password Page
                    },
                    child: Text("Forgot Password?"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
