import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DisplayMyPracticeScreen extends StatefulWidget {
  @override
  _DisplayMyPracticeScreenState createState() =>
      _DisplayMyPracticeScreenState();
}

class _DisplayMyPracticeScreenState extends State<DisplayMyPracticeScreen> {
  final _formKey = GlobalKey<FormState>();

  String fullName = '';
  String email = '';
  String password = '';
  String contactNumber = '';
  String companyName = '';
  String countryOfOrigin = '';
  int numberOfPractices = 1;
  String verificationCode = '';
  String enteredCode = '';
  String userId = ''; // 👈 Global variable to store user ID

  bool isLoading = false;
  String errorMessage = '';
  bool isEmailVerified = false;
  bool isVerificationSent = false;

  // Send Verification Email API Call
  Future<void> sendVerificationEmail() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final url = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/send-verification/");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        setState(() {
          isVerificationSent = true;
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Verification Sent"),
            content: Text(
                "A verification code has been sent to your email. Please check and enter the code."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              )
            ],
          ),
        );
      } else if (response.statusCode == 400) {
        setState(() {
          errorMessage = jsonDecode(response.body)["error"] ??
              "Email already registered. Please log in.";
        });
      } else {
        setState(() {
          errorMessage = jsonDecode(response.body)["error"] ??
              "Failed to send verification. Try again!";
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

  Future<void> verifyCode() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final url = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/verify-email/");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "verification_code": enteredCode}),
      );

      final responseData = jsonDecode(response.body);
      print("🔍 Response Status Code: ${response.statusCode}");
      print("🔍 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          isEmailVerified = true;
          userId = responseData["id"]; // 👈 Store `id` instead of `uuid`
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Email Verified"),
            content: Text("Your email has been successfully verified."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              )
            ],
          ),
        );
      } else {
        setState(() {
          errorMessage =
              responseData["error"] ?? "Incorrect verification code!";
        });
      }
    } catch (e) {
      print("❌ Error: $e");
      setState(() {
        errorMessage = "Network error. Please try again!";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> registerOwner() async {
    if (!isEmailVerified) {
      setState(() {
        errorMessage = "Please verify your email before proceeding.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final url = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/register/");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": userId, // 👈 Send stored `id` here
          "full_name": fullName,
          "password": password,
          "phone_number": contactNumber,
          "company_registered_name": companyName,
          "country_of_origin": countryOfOrigin,
          "number_of_practices": numberOfPractices,
        }),
      );

      final responseData = jsonDecode(response.body);
      print("🔍 Response Status Code: ${response.statusCode}");
      print("🔍 Response Body: ${response.body}");

      if (response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Success"),
            content: Text(
                "Registration Successful. Please check your email for confirmation."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              )
            ],
          ),
        );
      } else {
        setState(() {
          errorMessage =
              responseData["error"] ?? "Registration failed. Try again!";
        });
      }
    } catch (e) {
      print("❌ Error: $e");
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
      appBar: AppBar(title: Text("Owner Registration")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: "Email Address"),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => email = value,
                ),
                if (isVerificationSent)
                  TextFormField(
                    decoration: InputDecoration(labelText: "Verification Code"),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => enteredCode = value,
                  ),
                if (isVerificationSent)
                  ElevatedButton(
                    onPressed: verifyCode,
                    child: Text("Verify Code"),
                  ),
                if (!isVerificationSent)
                  ElevatedButton(
                    onPressed: sendVerificationEmail,
                    child: Text("Send Verification Code"),
                  ),
                if (isEmailVerified) ...[
                  TextFormField(
                    decoration: InputDecoration(labelText: "Full Name"),
                    onChanged: (value) => fullName = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Password"),
                    obscureText: true,
                    onChanged: (value) => password = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Contact Number"),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => contactNumber = value,
                  ),
                  TextFormField(
                    decoration:
                        InputDecoration(labelText: "Company Registered Name"),
                    onChanged: (value) => companyName = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Country of Origin"),
                    onChanged: (value) => countryOfOrigin = value,
                  ),
                  DropdownButtonFormField<int>(
                    value: numberOfPractices,
                    decoration:
                        InputDecoration(labelText: "Number of Practices"),
                    items: List.generate(
                      100,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text("${index + 1}"),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        numberOfPractices = value!;
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: registerOwner,
                    child: Text("Register"),
                  ),
                ],
                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                if (isLoading) CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
