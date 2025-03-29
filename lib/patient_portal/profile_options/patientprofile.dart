import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditDependentProfilePage extends StatefulWidget {
  final String dependentId; // This will hold the dependent's UUID

  EditDependentProfilePage({required this.dependentId});

  @override
  _EditDependentProfilePageState createState() =>
      _EditDependentProfilePageState();
}

class _EditDependentProfilePageState extends State<EditDependentProfilePage> {
  final _formKey = GlobalKey<FormState>(); // Form validation key

  // Local variables for storing form data
  String? fullName;
  String? relationship;
  String? dateOfBirth;
  String? gender;
  String? profilePictureUrl;
  String? nextAppointmentDate;
  String? nextAppointmentTime;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDependentDetails();
  }

  // Fetch the details of the dependent using the dependent's UUID
  Future<void> _fetchDependentDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/patients_dental/dependent-details/${widget.dependentId}/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dependent = data['dependent'];

        setState(() {
          fullName = dependent['full_name'];
          relationship = dependent['relationship'];
          dateOfBirth = dependent['date_of_birth'];
          gender = dependent['gender'];
          profilePictureUrl = dependent['profile_picture'];
          nextAppointmentDate = dependent['next_appointment_date'];
          nextAppointmentTime = dependent['next_appointment_time'];
          _isLoading = false;
        });
      } else {
        // Handle the error if the request fails
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog("Failed to load dependent data");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog("An error occurred while fetching data.");
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
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

  // Handle form submission
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Form is valid, so proceed with updating the data
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.put(
          Uri.parse(
              'https://dental-key-738b90a4d87a.herokuapp.com/patients_dental/dependent-update/${widget.dependentId}/'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'full_name': fullName,
            'relationship': relationship,
            'date_of_birth': dateOfBirth,
            'gender': gender,
            'next_appointment_date': nextAppointmentDate,
            'next_appointment_time': nextAppointmentTime,
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            _isLoading = false;
          });

          // Show success message and pop the screen
          _showSuccessDialog("Dependent details updated successfully");
        } else {
          setState(() {
            _isLoading = false;
          });
          _showErrorDialog("Failed to update dependent details.");
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog("An error occurred while updating data.");
      }
    }
  }

  // Show success dialog after updating the details
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to the previous screen
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Dependent Profile"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    // Full Name Text Field
                    TextFormField(
                      initialValue: fullName,
                      decoration: InputDecoration(labelText: 'Full Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the full name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        fullName = value;
                      },
                    ),
                    // Relationship Text Field
                    TextFormField(
                      initialValue: relationship,
                      decoration: InputDecoration(labelText: 'Relationship'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the relationship';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        relationship = value;
                      },
                    ),
                    // Date of Birth Text Field
                    TextFormField(
                      initialValue: dateOfBirth,
                      decoration: InputDecoration(labelText: 'Date of Birth'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the date of birth';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        dateOfBirth = value;
                      },
                    ),
                    // Gender Dropdown
                    DropdownButtonFormField<String>(
                      value: gender,
                      decoration: InputDecoration(labelText: 'Gender'),
                      items: ['Male', 'Female', 'Other']
                          .map((genderOption) => DropdownMenuItem(
                                child: Text(genderOption),
                                value: genderOption,
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          gender = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select the gender';
                        }
                        return null;
                      },
                    ),
                    // Next Appointment Date Text Field
                    TextFormField(
                      initialValue: nextAppointmentDate,
                      decoration:
                          InputDecoration(labelText: 'Next Appointment Date'),
                      onSaved: (value) {
                        nextAppointmentDate = value;
                      },
                    ),
                    // Next Appointment Time Text Field
                    TextFormField(
                      initialValue: nextAppointmentTime,
                      decoration:
                          InputDecoration(labelText: 'Next Appointment Time'),
                      onSaved: (value) {
                        nextAppointmentTime = value;
                      },
                    ),
                    // Save Button
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
