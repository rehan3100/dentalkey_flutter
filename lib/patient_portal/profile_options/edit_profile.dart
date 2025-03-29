import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class EditDependentPage extends StatefulWidget {
  final String patientId;
  final String dependentUuid;

  EditDependentPage({
    required this.patientId,
    required this.dependentUuid,
  });

  @override
  _EditDependentPageState createState() => _EditDependentPageState();
}

class _EditDependentPageState extends State<EditDependentPage> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? dependentDetails;
  bool isLoading = true;
  File? _selectedImage;

  // Text Editing Controllers
  TextEditingController fullNameController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  TextEditingController uniqueIdController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController additionalNotesController = TextEditingController();

  // Dropdown values
  String? selectedGender;
  String? selectedRelationship;

  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> relationshipOptions = [
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

  @override
  void initState() {
    super.initState();
    _fetchDependentDetails();
  }

  Future<void> _fetchDependentDetails() async {
    final url =
        'https://dental-key-738b90a4d87a.herokuapp.com/patients_dental/dependent/${widget.dependentUuid}/';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          dependentDetails = json.decode(response.body);
          isLoading = false;

          // Populate controllers and dropdowns with existing data
          fullNameController.text = dependentDetails?['full_name'] ?? '';
          dateOfBirthController.text = dependentDetails?['date_of_birth'] ?? '';
          uniqueIdController.text = dependentDetails?['unique_id_number'] ?? '';
          emailController.text = dependentDetails?['personal_email'] ?? '';
          contactNumberController.text =
              dependentDetails?['personal_contact_number'] ?? '';
          additionalNotesController.text =
              dependentDetails?['additional_notes'] ?? '';

          selectedGender = dependentDetails?['gender'];
          selectedRelationship = dependentDetails?['relationship'];
        });
      } else {
        throw Exception('Failed to load dependent details');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching dependent details: $error');
    }
  }

  Future<void> _updateDependentDetails() async {
    final url =
        'https://dental-key-738b90a4d87a.herokuapp.com/patients_dental/dependent/${widget.dependentUuid}/update/';
    final updatedData = {
      'full_name': fullNameController.text,
      'date_of_birth': dateOfBirthController.text,
      'gender': selectedGender,
      'relationship': selectedRelationship,
      'unique_id_number': uniqueIdController.text,
      'personal_email': emailController.text,
      'personal_contact_number': contactNumberController.text,
      'additional_notes': additionalNotesController.text,
    };

    try {
      final request = http.MultipartRequest('PUT', Uri.parse(url));

      // Add fields to the request
      updatedData.forEach((key, value) {
        request.fields[key] = value ?? '';
      });

      // Add the profile picture if selected
      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture', // Ensure this matches the field name in the backend
          _selectedImage!.path,
          filename: _selectedImage!.path
              .split('/')
              .last, // Ensure filename is included
        ));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dependent details updated successfully')),
        );
        Navigator.pop(context); // Return to the previous page
      } else {
        throw Exception('Failed to update dependent details');
      }
    } catch (error) {
      print('Error updating dependent details: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update dependent details')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _cropImage(File(pickedFile.path));
    }
  }

  Future<void> _cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.blueAccent,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Image',
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _selectedImage = File(croppedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Dependent Profile"),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!) as ImageProvider
                              : (dependentDetails?['profile_picture'] != null
                                  ? NetworkImage(
                                      '${dependentDetails!['profile_picture']}?timestamp=${DateTime.now().millisecondsSinceEpoch}',
                                    )
                                  : null),
                          child: _selectedImage == null &&
                                  dependentDetails?['profile_picture'] == null
                              ? Icon(Icons.camera_alt, size: 50)
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildReadOnlyField(
                        label: "Full Name", value: fullNameController.text),
                    _buildReadOnlyField(
                        label: "Date of Birth",
                        value: dateOfBirthController.text),
                    _buildReadOnlyField(label: "Gender", value: selectedGender),
                    _buildReadOnlyField(
                        label: "Relationship", value: selectedRelationship),
                    _buildReadOnlyField(
                        label: "Unique ID Number",
                        value: uniqueIdController.text),
                    _buildTextField(
                        label: "Email", controller: emailController),
                    _buildTextField(
                        label: "Contact Number",
                        controller: contactNumberController),
                    _buildTextField(
                        label: "Additional Notes",
                        controller: additionalNotesController),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _updateDependentDetails,
                        child: Text("Save Changes"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String? value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(12.0),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            child: Text(
              value ?? "N/A",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      {required String label, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
