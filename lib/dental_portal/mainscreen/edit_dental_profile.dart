import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:country_picker/country_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  final String accessToken;

  EditProfileScreen({required this.accessToken});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _emailController;
  late TextEditingController _fullNameController;
  late TextEditingController _genderController;
  late TextEditingController _institutionPracticeController;
  late TextEditingController _degreeAwardingBodyController;
  late TextEditingController _expectedYearOfGraduationController;
  late TextEditingController _membershipStatusController;

  bool _isLoading = true;
  bool _isError = false;

  String _selectedGender = 'Male';
  String _selectedCurrentStatus = 'Undergraduate Dental Student';
  String _phoneNumber = '';
  String _whatsappNumber = '';
  String _alternativeNumber = '';
  String _selectedCurrentCountry = '';
  String _selectedGraduationCountry = '';
  String _phoneNumberCountryCode = 'US';
  String _whatsappCountryCode = 'US';
  String _alternativeCountryCode = 'US';
  int _selectedYear = DateTime.now().year;
  String _profilePercentage = '';

  List<int> years = List<int>.generate(25, (index) => index + 2006);

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    print("Fetching profile data...");
    final response = await http.get(
      Uri.parse('https://dental-key-738b90a4d87a.herokuapp.com/users/profile/'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Content-Type': 'application/json',
      },
    );

    print("Response status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Profile data: $data");
      setState(() {
        _emailController = TextEditingController(text: data['email']);
        _fullNameController = TextEditingController(text: data['full_name']);
        _genderController = TextEditingController(text: data['gender']);
        _institutionPracticeController =
            TextEditingController(text: data['institution_practice']);
        _degreeAwardingBodyController =
            TextEditingController(text: data['degree_awarding_body']);
        _expectedYearOfGraduationController = TextEditingController(
            text: data['expected_year_of_graduation'].toString());
        _membershipStatusController =
            TextEditingController(text: data['membership_status']);

        _selectedGender = data['gender'] ?? 'Male';
        _selectedCurrentStatus =
            data['current_status'] ?? 'Undergraduate Dental Student';
        _selectedCurrentCountry = data['current_country'] ?? '';
        _selectedGraduationCountry = data['country_of_graduation'] ?? '';
        _selectedYear =
            data['expected_year_of_graduation'] ?? DateTime.now().year;
        _phoneNumber = data['phone_number'] ?? '';
        _whatsappNumber = data['whatsapp_number'] ?? '';
        _alternativeNumber = data['alternative_contact_number'] ?? '';
        _profilePercentage = data['profile_percentage'].toString();

        _saveProfilePercentage(_profilePercentage);

        _extractCountryCode(data['phone_number']).then((code) {
          setState(() {
            _phoneNumberCountryCode = code;
          });
        });
        _extractCountryCode(data['whatsapp_number']).then((code) {
          setState(() {
            _whatsappCountryCode = code;
          });
        });
        _extractCountryCode(data['alternative_contact_number']).then((code) {
          setState(() {
            _alternativeCountryCode = code;
          });
        });

        _isLoading = false;
        _isError = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  Future<void> _saveProfilePercentage(String profilePercentage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profilePercentage', profilePercentage);
  }

  Future<String> _extractCountryCode(String? phoneNumber) async {
    print("Extracting country code for phone number: $phoneNumber");
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final phoneNumberObj =
          await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber);
      print("Country code extracted: ${phoneNumberObj.isoCode}");
      return phoneNumberObj.isoCode ?? 'US';
    }
    return 'US';
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final Map<String, dynamic> profileData = {
        'email': _emailController.text,
        'full_name': _fullNameController.text,
        'phone_number': _phoneNumber,
        'gender': _selectedGender,
        'whatsapp_number': _whatsappNumber,
        'alternative_contact_number': _alternativeNumber,
        'current_country': _selectedCurrentCountry,
        'current_status': _selectedCurrentStatus,
        'institution_practice': _institutionPracticeController.text,
        'degree_awarding_body': _degreeAwardingBodyController.text,
        'expected_year_of_graduation': _selectedYear,
        'country_of_graduation': _selectedGraduationCountry,
        'membership_status': _membershipStatusController.text,
      };

      print("Updating profile with data: $profileData");

      final response = await http.put(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/users/profile/'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(profileData),
      );

      print("Update profile response status code: ${response.statusCode}");
      print("Update profile response body: ${response.body}");

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  void _showCountryPickerDialog(bool isCurrentCountry) {
    showCountryPicker(
      context: context,
      onSelect: (Country country) {
        print("Selected country: ${country.name}");
        setState(() {
          if (isCurrentCountry) {
            _selectedCurrentCountry = country.name;
          } else {
            _selectedGraduationCountry = country.name;
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isError
              ? Center(child: Text('Failed to load profile data'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          enabled: false,
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: _fullNameController,
                          decoration: InputDecoration(labelText: 'Full Name'),
                          enabled: false,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Profile Completed: $_profilePercentage%',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          onChanged: null,
                          items: ['Male', 'Female', 'Other']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: 'Gender',
                          ),
                          disabledHint: Text(_selectedGender),
                        ),
                        SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: _selectedCurrentStatus,
                          onChanged: (value) {
                            setState(() {
                              _selectedCurrentStatus = value!;
                            });
                          },
                          items: [
                            'Undergraduate Dental Student',
                            'General Dentist',
                            'Postgraduate Dental Student',
                            'Specialist Dentist'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: 'Current Status',
                          ),
                        ),
                        SizedBox(height: 20.0),
                        InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) {
                            _phoneNumber = number.phoneNumber ?? '';
                          },
                          selectorConfig: SelectorConfig(
                            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                            useEmoji: false,
                            leadingPadding: 10.0,
                          ),
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          inputDecoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(
                              color: Color(0xff385a92),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 10.0),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                          initialValue: PhoneNumber(
                            phoneNumber: _phoneNumber,
                            isoCode: _phoneNumberCountryCode,
                          ),
                        ),
                        SizedBox(height: 20.0),
                        InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) {
                            _whatsappNumber = number.phoneNumber ?? '';
                          },
                          selectorConfig: SelectorConfig(
                            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                            useEmoji: false,
                            leadingPadding: 10.0,
                          ),
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          inputDecoration: InputDecoration(
                            labelText: 'WhatsApp Number',
                            labelStyle: TextStyle(
                              color: Color(0xff385a92),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 10.0),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                          initialValue: PhoneNumber(
                            phoneNumber: _whatsappNumber,
                            isoCode: _whatsappCountryCode,
                          ),
                        ),
                        SizedBox(height: 20.0),
                        InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) {
                            _alternativeNumber = number.phoneNumber ?? '';
                          },
                          selectorConfig: SelectorConfig(
                              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                              useEmoji: false,
                              leadingPadding: 10.0),
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          inputDecoration: InputDecoration(
                            labelText: 'Alternative Contact Number',
                            labelStyle: TextStyle(
                              color: Color(0xff385a92),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 10.0),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                          initialValue: PhoneNumber(
                            phoneNumber: _alternativeNumber,
                            isoCode: _alternativeCountryCode,
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: _institutionPracticeController,
                          decoration: InputDecoration(
                              labelText: 'Institution/Practice Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your institution';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            _showCountryPickerDialog(true);
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: TextEditingController(
                                  text: _selectedCurrentCountry),
                              decoration: InputDecoration(
                                labelText: _selectedCurrentCountry.isEmpty
                                    ? 'Select Current Country'
                                    : 'Selected Current Country',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 12.0),
                                suffixIcon: Icon(Icons.arrow_drop_down),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            _showCountryPickerDialog(false);
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: TextEditingController(
                                  text: _selectedGraduationCountry),
                              decoration: InputDecoration(
                                labelText: _selectedGraduationCountry.isEmpty
                                    ? 'Select Country of Graduation'
                                    : 'Selected Country of Graduation',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 12.0),
                                suffixIcon: Icon(Icons.arrow_drop_down),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        DropdownButtonFormField<int>(
                          value: _selectedYear,
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedYear = newValue!;
                            });
                          },
                          items: years.map<DropdownMenuItem<int>>(
                            (int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            },
                          ).toList(),
                          decoration: InputDecoration(
                            labelText: 'Graduation Year',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _degreeAwardingBodyController,
                          decoration: InputDecoration(
                            labelText: 'Degree Awarding Body',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your degree awarding body';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _updateProfile,
                            child: Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
