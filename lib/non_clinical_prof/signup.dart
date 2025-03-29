import 'dart:convert';
import 'package:dental_key/non_clinical_prof/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NonClinicalSignupScreen extends StatefulWidget {
  @override
  _NonClinicalSignupScreenState createState() =>
      _NonClinicalSignupScreenState();
}

class _NonClinicalSignupScreenState extends State<NonClinicalSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController experienceYearsController =
      TextEditingController();
  final TextEditingController experienceMonthsController =
      TextEditingController();

  String? selectedRoleId;
  List<Map<String, dynamic>> roles = [];

  @override
  void initState() {
    super.initState();
    fetchRoles();
  }

  Future<void> fetchRoles() async {
    final response = await http.get(Uri.parse(
        'https://dental-key-738b90a4d87a.herokuapp.com/users/non-clinical-roles/'));
    if (response.statusCode == 200) {
      setState(() {
        roles = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load roles')));
    }
  }

  Future<void> signup() async {
    if (!_formKey.currentState!.validate() || selectedRoleId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please select a role')));
      return;
    }

    final body = {
      'email': emailController.text.trim(),
      'full_name': fullNameController.text.trim(),
      'phone_number': phoneController.text.trim(),
      'role_id': selectedRoleId,
      'experience_years':
          int.tryParse(experienceYearsController.text.trim()) ?? 0,
      'experience_months':
          int.tryParse(experienceMonthsController.text.trim()) ?? 0,
      'password': passwordController.text.trim(),
    };

    final response = await http.post(
      Uri.parse(
          'https://dental-key-738b90a4d87a.herokuapp.com/users/non-clinical/signup/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Signup successful')));
      Navigator.pop(context); // or navigate to login screen
    } else {
      final res = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Signup failed: ${res['error'] ?? 'Try again'}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Non-Clinical Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (val) => val!.isEmpty ? 'Enter email' : null),
              TextFormField(
                  controller: fullNameController,
                  decoration: InputDecoration(labelText: 'Full Name'),
                  validator: (val) => val!.isEmpty ? 'Enter name' : null),
              TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone Number')),
              TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (val) =>
                      val!.length < 6 ? 'Password too short' : null),
              TextFormField(
                  controller: experienceYearsController,
                  decoration: InputDecoration(labelText: 'Experience Years'),
                  keyboardType: TextInputType.number),
              TextFormField(
                  controller: experienceMonthsController,
                  decoration: InputDecoration(labelText: 'Experience Months'),
                  keyboardType: TextInputType.number),
              SizedBox(height: 16),

              /// ✅ Role Dropdown
              DropdownButtonFormField<String>(
                value: selectedRoleId,
                items: roles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role['id'],
                    child: Text(role['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRoleId = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Select Role',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null ? 'Please select a role' : null,
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: signup,
                child: Text('Sign Up'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already signed up? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => NonClinicalLoginScreen()),
                      );
                    },
                    child: Text("Login Now"),
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
