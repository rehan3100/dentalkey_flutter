import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPracticeScreen extends StatefulWidget {
  final String ownerId;

  AddPracticeScreen({required this.ownerId});

  @override
  _AddPracticeScreenState createState() => _AddPracticeScreenState();
}

class _AddPracticeScreenState extends State<AddPracticeScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isSubmitting = false;

  // Practice fields
  String practiceName = '';
  String gdcNumber = '';
  String cqcNumber = '';
  String practiceType = 'Mixed';
  String addressLine1 = '';
  String addressLine2 = '';
  String townCity = '';
  String county = '';
  String postcode = '';
  String phoneNumber = '';
  String email = '';
  String website = '';
  String facebook = '';
  String instagram = '';
  String linkedin = '';
  int chairs = 1;
  bool acceptsEmergency = true;
  bool teledental = true;
  bool acceptingNewNHSPatients = true;
  bool acceptingNewPrivatePatients = true;

  bool wheelchairAccess = true;
  String formatPostcode(String postcode) {
    postcode = postcode.trim().toUpperCase();

    if (!postcode.contains(" ") && postcode.length >= 5) {
      final firstPart = postcode.substring(0, postcode.length - 3);
      final lastPart = postcode.substring(postcode.length - 3);
      return "$firstPart $lastPart";
    }

    return postcode;
  }

  Future<void> submitPractice() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => isSubmitting = true);

    final url = Uri.parse(
        'https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/add-practice/');
    final body = {
      "owner": widget.ownerId,
      "practice_name": practiceName,
      "gdc_number": gdcNumber,
      "cqc_number": cqcNumber,
      "practice_type": practiceType,
      "address_line_1": addressLine1,
      "address_line_2": addressLine2,
      "city": townCity,
      "county_province": county,
      "postcode": formatPostcode(postcode),
      "phone_number": phoneNumber,
      "email": email,
      "website": website,
      "facebook_link": facebook,
      "instagram_link": instagram,
      "linkedin_link": linkedin,
      "number_of_chairs": chairs,
      "accepting_new_NHS_patients": acceptingNewNHSPatients,
      "accepting_new_private_patients": acceptingNewPrivatePatients,
      "accepts_emergency_patients": acceptsEmergency,
      "teledental": teledental,
      "wheelchair_accessible": wheelchairAccess,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Practice added successfully!')),
        );
        Navigator.pop(context); // Return to the management screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add practice.')),
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error. Please try again.')),
      );
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add New Practice")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField("Practice Name",
                  onSaved: (v) => practiceName = v!),
              buildTextField("GDC Number", onSaved: (v) => gdcNumber = v!),
              buildTextField("CQC Number", onSaved: (v) => cqcNumber = v!),
              buildDropdownField("Practice Type", ["NHS", "Private", "Mixed"],
                  (v) => practiceType = v!),
              buildTextField("Address Line 1",
                  onSaved: (v) => addressLine1 = v!),
              buildTextField("Address Line 2",
                  onSaved: (v) => addressLine2 = v!),
              buildTextField("Town/City", onSaved: (v) => townCity = v!),
              buildTextField("County", onSaved: (v) => county = v!),
              buildTextField("Postcode", onSaved: (v) => postcode = v!),
              buildTextField("Phone Number", onSaved: (v) => phoneNumber = v!),
              buildTextField("Email", onSaved: (v) => email = v!),
              buildTextField("Website", onSaved: (v) => website = v!),
              buildTextField("Facebook Link", onSaved: (v) => facebook = v!),
              buildTextField("Instagram Link", onSaved: (v) => instagram = v!),
              buildTextField("LinkedIn Link", onSaved: (v) => linkedin = v!),
              buildTextField("Number of Surgery Spaces",
                  inputType: TextInputType.number,
                  onSaved: (v) => chairs = int.tryParse(v!) ?? 1),
              buildCheckbox(
                  "Is your Practice accepting New NHS Patients?",
                  acceptingNewNHSPatients,
                  (v) => setState(() => acceptingNewNHSPatients = v!)),
              buildCheckbox(
                  "Is your Practice accepting New Private Patients?",
                  acceptingNewPrivatePatients,
                  (v) => setState(() => acceptingNewPrivatePatients = v!)),
              buildCheckbox(
                  "Is your practice taking Emergency Patients during your opening hours?",
                  acceptsEmergency,
                  (v) => setState(() => acceptsEmergency = v!)),
              buildCheckbox("Is your practice Providing TeleDental Service?",
                  teledental, (v) => setState(() => teledental = v!)),
              buildCheckbox(
                  "Is your practice Accessible for Wheelchair Users?",
                  wheelchairAccess,
                  (v) => setState(() => wheelchairAccess = v!)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSubmitting ? null : submitPractice,
                child: isSubmitting
                    ? CircularProgressIndicator()
                    : Text("Submit Practice"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label,
      {TextInputType inputType = TextInputType.text,
      required void Function(String?) onSaved}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        keyboardType: inputType,
        onSaved: onSaved,
      ),
    );
  }

  Widget buildDropdownField(
      String label, List<String> options, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        value: options[2],
        onChanged: onChanged,
        items: options
            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
            .toList(),
      ),
    );
  }

  Widget buildCheckbox(
      String label, bool value, void Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
