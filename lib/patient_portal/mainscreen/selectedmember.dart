import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PatientMainPortalPage extends StatefulWidget {
  final String patientId;
  final String dependentId; // Add the dependentId to receive it

  PatientMainPortalPage({required this.patientId, required this.dependentId});

  @override
  _PatientMainPortalPageState createState() => _PatientMainPortalPageState();
}

class _PatientMainPortalPageState extends State<PatientMainPortalPage> {
  bool _isLoading = true;
  Map<String, dynamic>? dependent;

  @override
  void initState() {
    super.initState();
    _fetchDependentData();
  }

  // Fetch dependent data
  Future<void> _fetchDependentData() async {
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

        setState(() {
          dependent = data;
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch dependent data");
      }
    } catch (e) {
      _showErrorDialog("Failed to load dependent data. Please try again.");
      setState(() {
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dependent Details"),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dependent?['full_name'] ?? 'Loading...',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                      "Age: ${_calculateAge(DateTime.parse(dependent?['date_of_birth'] ?? ''))}"),
                  SizedBox(height: 5),
                  Text("Relationship: ${dependent?['relationship']}"),
                  // Add more dependent details as needed
                ],
              ),
            ),
    );
  }

  // Calculate age from the date of birth
  int _calculateAge(DateTime dateOfBirth) {
    final today = DateTime.now();
    final age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      return age - 1;
    }
    return age;
  }
}
