import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppointmentRequestScreen extends StatefulWidget {
  final String practiceId;
  final String patientId;
  final String dependentUuid;

  AppointmentRequestScreen({
    required this.practiceId,
    required this.patientId,
    required this.dependentUuid,
  });

  @override
  _AppointmentRequestScreenState createState() =>
      _AppointmentRequestScreenState();
}

class _AppointmentRequestScreenState extends State<AppointmentRequestScreen> {
  String patientType = "Any";
  String mode = "In-Person";
  String nature = "Routine";
  String? routineReason;
  String? emergencyReason;
  String? description;
  List<String> preferredDays = [];
  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  bool consentGiven = false;

  List<String> allDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  void submitRequest() async {
    if (!consentGiven) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please give consent.")));
      return;
    }

    final url = Uri.parse(
        'https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/request-appointment/');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "practice": widget.practiceId,
        "requested_by": widget.patientId,
        "requested_for": widget.dependentUuid,
        "patient_type": patientType,
        "mode": mode,
        "nature": nature,
        "routine_reason": routineReason,
        "emergency_reason": emergencyReason,
        "custom_description": description,
        "preferred_days": preferredDays,
        "preferred_time_from": fromTime?.format(context),
        "preferred_time_to": toTime?.format(context),
        "consent_given": true
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Appointment request submitted!")));
      Navigator.pop(context);
    } else {
      print(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit appointment request.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Request Appointment")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Patient Type"),
              value: patientType,
              items: ["NHS", "Private", "Any"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => patientType = val!),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Mode"),
              value: mode,
              items: ["In-Person", "Teledental"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => mode = val!),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Nature"),
              value: nature,
              items: ["Routine", "Emergency"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => nature = val!),
            ),
            if (nature == "Routine")
              TextFormField(
                decoration: InputDecoration(labelText: "Routine Reason"),
                onChanged: (val) => routineReason = val,
              ),
            if (nature == "Emergency")
              TextFormField(
                decoration: InputDecoration(labelText: "Emergency Reason"),
                onChanged: (val) => emergencyReason = val,
              ),
            TextFormField(
              decoration: InputDecoration(labelText: "Custom Description"),
              maxLines: 3,
              onChanged: (val) => description = val,
            ),
            SizedBox(height: 10),
            Text("Preferred Days"),
            Wrap(
              spacing: 8,
              children: allDays.map((day) {
                return FilterChip(
                  label: Text(day),
                  selected: preferredDays.contains(day),
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        preferredDays.add(day);
                      } else {
                        preferredDays.remove(day);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                        "From: ${fromTime?.format(context) ?? 'Not selected'}"),
                    onTap: () async {
                      TimeOfDay? time = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      if (time != null) setState(() => fromTime = time);
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                        "To: ${toTime?.format(context) ?? 'Not selected'}"),
                    onTap: () async {
                      TimeOfDay? time = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      if (time != null) setState(() => toTime = time);
                    },
                  ),
                ),
              ],
            ),
            CheckboxListTile(
              title:
                  Text("I give my consent to share this info with the clinic"),
              value: consentGiven,
              onChanged: (val) => setState(() => consentGiven = val ?? false),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: submitRequest,
              icon: Icon(Icons.send),
              label: Text("Submit Request"),
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50)),
            )
          ],
        ),
      ),
    );
  }
}
