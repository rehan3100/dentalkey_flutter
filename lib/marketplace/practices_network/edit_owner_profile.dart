import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditOwnerProfileScreen extends StatefulWidget {
  final Map<String, dynamic> ownerDetails;

  EditOwnerProfileScreen({required this.ownerDetails});

  @override
  _EditOwnerProfileScreenState createState() => _EditOwnerProfileScreenState();
}

class _EditOwnerProfileScreenState extends State<EditOwnerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController companyController;
  late TextEditingController countryController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final details = widget.ownerDetails;
    nameController = TextEditingController(text: details['full_name'] ?? '');
    phoneController =
        TextEditingController(text: details['phone_number'] ?? '');
    companyController =
        TextEditingController(text: details['company_registered_name'] ?? '');
    countryController =
        TextEditingController(text: details['country_of_origin'] ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    companyController.dispose();
    countryController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    final updatedData = {
      "id": widget.ownerDetails['id'].toString(),
      "full_name": nameController.text.trim(),
      "phone_number": phoneController.text.trim(),
      "company_registered_name": companyController.text.trim(),
      "country_of_origin": countryController.text.trim(),
    };

    final url = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/update-profile/");
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedData),
    );

    setState(() => isSaving = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
      Navigator.pop(context, true); // Return to previous screen and refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildField(label: "Full Name", controller: nameController),
              buildField(
                  label: "Phone Number",
                  controller: phoneController,
                  keyboard: TextInputType.phone),
              buildField(label: "Company Name", controller: companyController),
              buildField(label: "Country", controller: countryController),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text(isSaving ? "Saving..." : "Save Changes"),
                onPressed: isSaving ? null : saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.teal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField(
      {required String label,
      required TextEditingController controller,
      TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (value) => value == null || value.trim().isEmpty
            ? "Please enter $label"
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
