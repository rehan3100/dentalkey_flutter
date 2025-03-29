import 'dart:convert';
import 'package:dental_key/non_clinical_prof/signup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NonClinicalLoginScreen extends StatefulWidget {
  @override
  _NonClinicalLoginScreenState createState() => _NonClinicalLoginScreenState();
}

class _NonClinicalLoginScreenState extends State<NonClinicalLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    final body = {
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
    };

    final response = await http.post(
      Uri.parse(
          "https://dental-key-738b90a4d87a.herokuapp.com/users/non-clinical/login/"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      final user = res['user'];

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login successful! Welcome ${user['full_name']}'),
      ));

      // TODO: Navigate to dashboard or home screen
    } else {
      final res = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'] ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Non-Clinical Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator: (val) => val!.isEmpty ? "Enter your email" : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (val) => val!.isEmpty ? "Enter your password" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) login();
                },
                child: Text("Login"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Not signed up? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => NonClinicalSignupScreen()),
                      );
                    },
                    child: Text("Sign Up Now"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
