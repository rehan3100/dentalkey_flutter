import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UpgradeMembershipPage extends StatefulWidget {
  final String patientId;
  UpgradeMembershipPage({required this.patientId});

  @override
  _UpgradeMembershipPageState createState() => _UpgradeMembershipPageState();
}

class _UpgradeMembershipPageState extends State<UpgradeMembershipPage> {
  String selectedMembership = '';

  void _updateMembership() async {
    try {
      final response = await http.put(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/patients_dental/manage/${widget.patientId}/'),
        body: jsonEncode({'membership_type': selectedMembership}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Navigator.pop(context); // Close this screen
        _showSuccessDialog();
      } else {
        throw Exception("Failed to update membership type");
      }
    } catch (e) {
      _showErrorDialog("Failed to update membership. Please try again.");
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text('Membership type updated successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pop(context); // Return to DependentsListPage
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

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

  void _confirmUpgrade() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Upgrade'),
        content:
            Text('Are you sure you want to upgrade to $selectedMembership?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _updateMembership();
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upgrade Membership'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('Silver'),
            trailing: Radio<String>(
              value: 'Silver',
              groupValue: selectedMembership,
              onChanged: (value) {
                setState(() {
                  selectedMembership = value!;
                });
              },
            ),
          ),
          ListTile(
            title: Text('Gold'),
            trailing: Radio<String>(
              value: 'Gold',
              groupValue: selectedMembership,
              onChanged: (value) {
                setState(() {
                  selectedMembership = value!;
                });
              },
            ),
          ),
          ListTile(
            title: Text('Diamond'),
            trailing: Radio<String>(
              value: 'Diamond',
              groupValue: selectedMembership,
              onChanged: (value) {
                setState(() {
                  selectedMembership = value!;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: selectedMembership.isNotEmpty ? _confirmUpgrade : null,
              child: Text('Upgrade'),
            ),
          ),
        ],
      ),
    );
  }
}
