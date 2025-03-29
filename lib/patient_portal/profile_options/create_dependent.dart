import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateDependentPage extends StatefulWidget {
  final String patientId;

  CreateDependentPage({required this.patientId});

  @override
  _CreateDependentPageState createState() => _CreateDependentPageState();
}

class _CreateDependentPageState extends State<CreateDependentPage> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  final _fullNameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _uniqueIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _additionalNotesController = TextEditingController();
  final _appointmentDateController = TextEditingController();
  final _appointmentTimeController = TextEditingController();

  // Gender and Relationship Dropdown values
  String? _selectedGender;
  String? _selectedRelationship;

  // Gender options
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  // Relationship options
  final List<String> _relationshipOptions = [
    'Self',
    'Mother',
    'Father',
    'Sister',
    'Brother',
    'Daughter',
    'Son',
    'Spouse',
    'Partner',
    'Grandmother',
    'Grandfather',
    'Granddaughter',
    'Grandson',
    'Aunt',
    'Uncle',
    'Niece',
    'Nephew',
    'Cousin',
    'Stepfather',
    'Stepmother',
    'Stepsister',
    'Stepbrother',
    'Stepdaughter',
    'Stepson',
    'Mother-in-law',
    'Father-in-law',
    'Sister-in-law',
    'Brother-in-law',
    'Daughter-in-law',
    'Son-in-law',
    'Guardian',
    'Care Worker',
    'Care Seeker',
    'Ward',
    'Friend',
    'Colleague',
    'Neighbor',
    'Other',
  ];

  // Function to submit the form
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      print("Form is valid. Preparing to submit...");
      print({
        'full_name': _fullNameController.text,
        'date_of_birth': _dateOfBirthController.text,
        'gender': _selectedGender,
        'relationship': _selectedRelationship,
        'unique_id_number': _uniqueIdController.text,
        'personal_email': _emailController.text,
        'personal_contact_number': _contactNumberController.text,
        'additional_notes': _additionalNotesController.text,
        'next_appointment_date': _appointmentDateController.text,
        'next_appointment_time': _appointmentTimeController.text,
      });

      try {
        final response = await http.post(
          Uri.parse(
              'https://dental-key-738b90a4d87a.herokuapp.com/patients_dental/create-dependent/${widget.patientId}/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'full_name': _fullNameController.text,
            'date_of_birth': _dateOfBirthController.text,
            'gender': _selectedGender,
            'relationship': _selectedRelationship,
            'unique_id_number': _uniqueIdController.text,
            'personal_email': _emailController.text,
            'personal_contact_number': _contactNumberController.text,
            'additional_notes': _additionalNotesController.text,
            'next_appointment_date': _appointmentDateController.text,
            'next_appointment_time': _appointmentTimeController.text,
          }),
        );

        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        if (response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          _showSuccessDialog(responseData['message']);
        } else {
          final responseData = jsonDecode(response.body);
          _showErrorDialog(
              responseData['error'] ?? 'Failed to create dependent');
        }
      } catch (e) {
        print("Error occurred: $e");
        _showErrorDialog('An error occurred. Please try again.');
      }
    } else {
      print("Form is not valid. Please check the input fields.");
    }
  }

  // Success dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
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

  // Date Picker
  Future<void> _pickDate(TextEditingController controller,
      {bool allowFuture = false}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: allowFuture ? DateTime(2100) : DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      final formattedTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      ).toIso8601String().split('T')[1].split('.')[0]; // Format to hh:mm:ss
      setState(() {
        controller.text = formattedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Dependent'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Full Name
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(labelText: 'Full Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter full name' : null,
                ),

                // Date of Birth
                TextFormField(
                  controller: _dateOfBirthController,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _pickDate(_dateOfBirthController),
                    ),
                  ),
                  readOnly: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Please select date of birth' : null,
                ),

                // Gender Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Gender'),
                  value: _selectedGender,
                  items: _genderOptions
                      .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select gender' : null,
                ),

                // Relationship Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Relationship'),
                  value: _selectedRelationship,
                  items: _relationshipOptions
                      .map((relationship) => DropdownMenuItem(
                            value: relationship,
                            child: Text(relationship),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRelationship = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select relationship' : null,
                ),

                // Unique ID
                TextFormField(
                  controller: _uniqueIdController,
                  decoration: InputDecoration(
                    labelText: 'Unique ID (e.g. NHS/Social Security)',
                  ),
                ),

                // Personal Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Personal Email'),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      return regex.hasMatch(value)
                          ? null
                          : 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                // Personal Contact Number
                TextFormField(
                  controller: _contactNumberController,
                  decoration:
                      InputDecoration(labelText: 'Personal Contact Number'),
                ),

                // Additional Notes
                TextFormField(
                  controller: _additionalNotesController,
                  decoration: InputDecoration(labelText: 'Additional Notes'),
                  maxLines: 3,
                ),

                // Next Appointment Date
                TextFormField(
                  controller: _appointmentDateController,
                  decoration: InputDecoration(
                    labelText: 'Next Appointment Date',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _pickDate(_appointmentDateController,
                          allowFuture: true),
                    ),
                  ),
                  readOnly: true,
                ),

                // Next Appointment Time
                TextFormField(
                  controller: _appointmentTimeController,
                  decoration: InputDecoration(
                    labelText: 'Next Appointment Time',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: () => _pickTime(_appointmentTimeController),
                    ),
                  ),
                  readOnly: true,
                ),

                // Submit Button
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Create Dependent'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
