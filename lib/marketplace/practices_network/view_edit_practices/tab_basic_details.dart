import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BasicDetailsScreen extends StatefulWidget {
  final String ownerId;
  final String practiceId;

  BasicDetailsScreen({required this.ownerId, required this.practiceId});

  @override
  _BasicDetailsScreenState createState() => _BasicDetailsScreenState();
}

class _BasicDetailsScreenState extends State<BasicDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  bool isSaving = false;
  bool isDeleting = false;

  // Practice fields
  String name = '';
  String gdc = '';
  String cqc = '';
  String email = '';
  String phone = '';
  String website = '';
  int chairs = 1;
  bool acceptsEmergency = true;
  bool teledental = true;
  bool acceptingNewNHSPatients = true;
  bool acceptingNewPrivatePatients = true;

  bool wheelchairAccessible = true;
  String addressLine1 = '';
  String addressLine2 = '';
  String townCity = '';
  String county = '';
  String postcode = '';
  String country = '';
  String facebook = '';
  String instagram = '';
  String linkedin = '';

  @override
  void initState() {
    super.initState();
    fetchPracticeDetails();
  }

  Future<void> fetchPracticeDetails() async {
    final url = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/get-practice/${widget.practiceId}/");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          name = data['practice_name'] ?? '';
          gdc = data['gdc_number'] ?? '';
          cqc = data['cqc_number'] ?? '';
          email = data['email'] ?? '';
          phone = data['phone_number'] ?? '';
          website = data['website'] ?? '';
          chairs = data['number_of_chairs'] ?? 1;
          addressLine1 = data['address_line_1'] ?? '';
          addressLine2 = data['address_line_2'] ?? '';
          townCity = data['city'] ?? '';
          county = data['county_province'] ?? '';
          postcode = data['postcode'] ?? '';
          country = data['country'] ?? '';
          facebook = data['facebook_link'] ?? '';
          instagram = data['instagram_link'] ?? '';
          linkedin = data['linkedin_link'] ?? '';
          teledental = data['teledental'] ?? true;
          acceptsEmergency = data['accepts_emergency_patients'] ?? true;
          acceptingNewNHSPatients = data['accepting_new_NHS_patients'] ?? true;
          acceptingNewPrivatePatients =
              data['accepting_new_private_patients'] ?? true;

          wheelchairAccessible = data['wheelchair_accessible'] ?? true;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load practice.");
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> updatePractice() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => isSaving = true);

    final url = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/update-practice/${widget.practiceId}/");

    final body = jsonEncode({
      "practice_name": name,
      "gdc_number": gdc,
      "cqc_number": cqc,
      "email": email,
      "phone_number": phone,
      "website": website,
      "number_of_chairs": chairs,
      "accepting_new_NHS_patients": acceptingNewNHSPatients,
      "accepting_new_private_patients": acceptingNewPrivatePatients,
      "teledental": teledental,
      "accepts_emergency_patients": acceptsEmergency,
      "wheelchair_accessible": wheelchairAccessible,
    });

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Practice updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to update practice.')),
        );
      }
    } catch (e) {
      print('❌ Error: $e');
    }

    setState(() => isSaving = false);
  }

  Future<void> deletePractice() async {
    setState(() => isDeleting = true);
    final url = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/delete-practice/${widget.practiceId}");

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("🗑️ Practice deleted successfully!")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to delete practice.")),
        );
      }
    } catch (e) {
      print('❌ Delete Error: $e');
    }
    setState(() => isDeleting = false);
  }

  void showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Practice"),
        content: Text("Are you sure you want to delete this practice?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              deletePractice();
            },
            icon: Icon(Icons.delete),
            label: Text("Delete"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());

    return Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            buildField("Practice Name",
                initial: name, onSaved: (v) => name = v!),
            buildField("GDC Number", initial: gdc, onSaved: (v) => gdc = v!),
            buildField("CQC Number", initial: cqc, onSaved: (v) => cqc = v!),
            buildField("Email", initial: email, onSaved: (v) => email = v!),
            buildField("Phone Number",
                initial: phone, onSaved: (v) => phone = v!),
            buildField("Website",
                initial: website, onSaved: (v) => website = v!),
            buildField("Number of Surgery Spaces",
                inputType: TextInputType.number,
                initial: chairs.toString(),
                onSaved: (v) => chairs = int.tryParse(v ?? "1") ?? 1),
            CheckboxListTile(
              title: Text("Is your Practice accepting New NHS Patients?"),
              value: acceptingNewNHSPatients,
              onChanged: (val) =>
                  setState(() => acceptingNewNHSPatients = val!),
            ),
            CheckboxListTile(
              title: Text("Is your Practice accepting New Private Patients?"),
              value: acceptingNewPrivatePatients,
              onChanged: (val) =>
                  setState(() => acceptingNewPrivatePatients = val!),
            ),
            CheckboxListTile(
              title: Text("Is your Practice providing teledental service?"),
              value: teledental,
              onChanged: (val) => setState(() => teledental = val!),
            ),
            CheckboxListTile(
              title: Text(
                  "Is your practice taking Emergency Patients during your opening hours?"),
              value: acceptsEmergency,
              onChanged: (val) => setState(() => acceptsEmergency = val!),
            ),
            CheckboxListTile(
              title: Text("Is your practice Accessible for Wheelchair Users?"),
              value: wheelchairAccessible,
              onChanged: (val) => setState(() => wheelchairAccessible = val!),
            ),
            buildField("Address Line 1",
                initial: addressLine1, onSaved: (v) => addressLine1 = v!),
            buildField("Address Line 2",
                initial: addressLine2, onSaved: (v) => addressLine2 = v!),
            buildField("Town/City",
                initial: townCity, onSaved: (v) => townCity = v!),
            buildField("County", initial: county, onSaved: (v) => county = v!),
            buildField("Postcode",
                initial: postcode, onSaved: (v) => postcode = v!),
            buildField("Country",
                initial: country, onSaved: (v) => country = v!),
            buildField("Facebook",
                initial: facebook, onSaved: (v) => facebook = v!),
            buildField("Instagram",
                initial: instagram, onSaved: (v) => instagram = v!),
            buildField("LinkedIn",
                initial: linkedin, onSaved: (v) => linkedin = v!),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isSaving ? null : updatePractice,
              icon: Icon(Icons.save),
              label: Text("Save Changes"),
            ),
            SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: isDeleting ? null : showDeleteConfirmation,
              icon: Icon(Icons.delete, color: Colors.red),
              label:
                  Text("Delete Practice", style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildField(String label,
      {required String initial,
      TextInputType inputType = TextInputType.text,
      required void Function(String?) onSaved}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: initial,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        onSaved: onSaved,
      ),
    );
  }
}
