import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import intl for date formatting
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class UpdateProfilePage extends StatefulWidget {
  final String patientId;
  UpdateProfilePage({required this.patientId});

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  bool _isLoading = false;

  // Form fields for updating the profile
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _countyController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _countryController = TextEditingController();
  String _emergencyContact = ''; // Store the emergency contact number

  // Non-changeable fields
  String patientName = '';
  String email = '';
  String phoneNumber = '';
  String dateJoined = ''; // We'll format this later
  String dateOfBirth = ''; // For formatted date of birth
  String formattedEmergencyContact = ''; // For formatted emergency contact
  String membershipType = '';

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

  // Fetch patient data to pre-fill the form
  Future<void> _fetchPatientData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/patients_dental/manage/${widget.patientId}/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Set non-changeable fields
          patientName = data['full_name'] ?? '';
          email = data['email'] ?? '';
          phoneNumber = data['phone_number'] ?? '';
          dateJoined = _formatDate(data['date_joined'] ?? '');
          dateOfBirth = _formatDate(
              data['date_of_birth'] ?? ''); // Get and format Date of Birth
          membershipType = data['membership_type'] ?? '';

          // Set editable fields
          _addressLine1Controller.text = data['address_line_1'] ?? '';
          _addressLine2Controller.text = data['address_line_2'] ?? '';
          _cityController.text = data['city'] ?? '';
          _countyController.text = data['county_province'] ?? '';
          _postcodeController.text = data['postcode'] ?? '';
          _countryController.text = data['country'] ?? '';
          _emergencyContact = data['emergency_contact'] ?? '';

          // Store the formatted emergency contact (if applicable)
          formattedEmergencyContact =
              data['formatted_emergency_contact'] ?? _emergencyContact;

          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load patient data");
      }
    } catch (e) {
      _showErrorDialog("Failed to load patient data.");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Format date to 'DD Month YYYY' (e.g., '04 January 2025')
  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd MMMM yyyy').format(parsedDate);
    } catch (e) {
      return 'Invalid Date'; // In case of an error in formatting
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

  // Update patient profile
  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.put(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/patients_dental/manage/${widget.patientId}/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'address_line_1': _addressLine1Controller.text,
          'address_line_2': _addressLine2Controller.text,
          'city': _cityController.text,
          'county_province': _countyController.text,
          'postcode': _postcodeController.text,
          'country': _countryController.text,
          'emergency_contact': _emergencyContact,
        }),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog();
      } else {
        throw Exception("Failed to update profile");
      }
    } catch (e) {
      _showErrorDialog("Failed to update profile.");
    }
  }

  // Open dialog to edit address
  void _openAddressDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Address"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _addressLine1Controller,
                  decoration: InputDecoration(
                    labelText: "Address Line 1",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _addressLine2Controller,
                  decoration: InputDecoration(
                    labelText: "Address Line 2",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: "City",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _countyController,
                  decoration: InputDecoration(
                    labelText: "County/Province",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _postcodeController,
                  decoration: InputDecoration(
                    labelText: "Postcode",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _countryController,
                  decoration: InputDecoration(
                    labelText: "Country",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Save updated data
                Navigator.of(context).pop();
                _updateProfile();
              },
              child: Text("Save Changes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without saving
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  // Open dialog to edit emergency contact
  void _openEmergencyContactDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Emergency Contact"),
          content: SingleChildScrollView(
            child: InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                _emergencyContact = number.phoneNumber ?? '';
              },
              selectorConfig: SelectorConfig(
                selectorType: PhoneInputSelectorType.DIALOG,
              ),
              inputDecoration: InputDecoration(
                labelText: 'Enter Emergency Contact Number',
                border: OutlineInputBorder(),
              ),
              initialValue: PhoneNumber(isoCode: 'US'),
              keyboardType: TextInputType.phone,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Save updated emergency contact
                Navigator.of(context).pop();
                _updateProfile();
              },
              child: Text("Save Changes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without saving
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Profile"),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Read-only fields in cards
                  Card(
                    elevation: 5,
                    margin: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text('Name: $patientName'),
                      tileColor: Colors.blue[50],
                    ),
                  ),
                  Card(
                    elevation: 5,
                    margin: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text('Email: $email'),
                      tileColor: Colors.blue[50],
                    ),
                  ),
                  Card(
                    elevation: 5,
                    margin: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text('Phone Number: $phoneNumber'),
                      tileColor: Colors.blue[50],
                    ),
                  ),
                  Card(
                    elevation: 5,
                    margin: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text('Date Joined: $dateJoined'),
                      tileColor: Colors.blue[50],
                    ),
                  ),
                  Card(
                    elevation: 5,
                    margin: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text('Date of Birth: $dateOfBirth'),
                      tileColor: Colors.blue[50],
                    ),
                  ),
                  Card(
                    elevation: 5,
                    margin: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text('Membership Type: $membershipType'),
                      tileColor: Colors.blue[50],
                    ),
                  ),

                  // Address Card with pencil icon
                  Card(
                    elevation: 5,
                    margin: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text('Address'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Address Line 1: ${_addressLine1Controller.text}'),
                          Text(
                              'Address Line 2: ${_addressLine2Controller.text}'),
                          Text('City: ${_cityController.text}'),
                          Text('County/Province: ${_countyController.text}'),
                          Text('Postcode: ${_postcodeController.text}'),
                          Text('Country: ${_countryController.text}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: _openAddressDialog,
                      ),
                    ),
                  ),

                  // Emergency Contact Card with pencil icon
                  Card(
                    elevation: 5,
                    margin: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text('Emergency Contact'),
                      subtitle: Text(formattedEmergencyContact),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: _openEmergencyContactDialog,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text('Profile updated successfully!'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pop(context); // Go back to previous screen
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
