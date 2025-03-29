import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UpdateMedicalRecordsPage extends StatefulWidget {
  final String dependentUuid;

  UpdateMedicalRecordsPage({required this.dependentUuid});

  @override
  _UpdateMedicalRecordsPageState createState() =>
      _UpdateMedicalRecordsPageState();
}

class _UpdateMedicalRecordsPageState extends State<UpdateMedicalRecordsPage> {
  Map<String, dynamic> medicalRecords = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMedicalRecords();
  }

  Future<void> _fetchMedicalRecords() async {
    final url =
        'https://dental-key-738b90a4d87a.herokuapp.com/patients_dental/dependent/${widget.dependentUuid}/medical-record/';
    print('Fetching medical records from: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          medicalRecords = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print(
            'Failed to fetch medical records. Status code: ${response.statusCode}');
        throw Exception('Failed to fetch medical records');
      }
    } catch (error) {
      print('Error fetching medical records: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateMedicalRecords() async {
    final url =
        'https://dental-key-738b90a4d87a.herokuapp.com/patients_dental/dependent/${widget.dependentUuid}/update-medical-record/';

    try {
      final response = await http.put(
        Uri.parse(url),
        body: json.encode(medicalRecords),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        print('Medical records updated successfully');
        Navigator.pop(context);
      } else {
        print(
            'Failed to update medical records. Status code: ${response.statusCode}');
        throw Exception('Failed to update medical records');
      }
    } catch (error) {
      print('Error updating medical records: $error');
    }
  }

  Widget _buildToggleList(Map<String, bool> options, String title) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...options.entries.map((entry) {
              return SwitchListTile(
                title: Text(entry.key),
                value: entry.value,
                onChanged: (value) {
                  setState(() {
                    options[entry.key] = value;
                  });
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsForm(List<Map<String, dynamic>> medications) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Medications",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...medications.map((medication) {
              return ListTile(
                title: TextFormField(
                  initialValue: medication['medicine_name'],
                  decoration: InputDecoration(labelText: "Medicine Name"),
                  onChanged: (value) {
                    medication['medicine_name'] = value;
                  },
                ),
                subtitle: TextFormField(
                  initialValue: medication['dosage'],
                  decoration: InputDecoration(labelText: "Dosage"),
                  onChanged: (value) {
                    medication['dosage'] = value;
                  },
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      medications.remove(medication);
                    });
                  },
                ),
              );
            }).toList(),
            TextButton.icon(
              icon: Icon(Icons.add),
              label: Text("Add Medication"),
              onPressed: () {
                setState(() {
                  medications.add({"medicine_name": "", "dosage": ""});
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Medical Records"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateMedicalRecords,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildToggleList(
                  medicalRecords['medical_problems'] ?? {},
                  "Diseases",
                ),
                _buildToggleList(
                  medicalRecords['allergies'] ?? {},
                  "Allergies",
                ),
                _buildMedicationsForm(
                  List<Map<String, dynamic>>.from(
                      medicalRecords['medications'] ?? []),
                ),
              ],
            ),
    );
  }
}
