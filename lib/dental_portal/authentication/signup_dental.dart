import 'package:dental_key/dental_portal/authentication/login_dental.dart';
import 'package:dental_key/dental_portal/authentication/modal_signup_dental.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:flutter/gestures.dart';
import 'package:country_picker/country_picker.dart';
import 'dart:io';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:file_picker/file_picker.dart';

class EmailValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}

class PasswordValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    } else if (!RegExp(r'.*[A-Z].*').hasMatch(value)) {
      return 'At least one uppercase letter';
    } else if (!RegExp(r'.*[a-z].*').hasMatch(value)) {
      return 'At least one lowercase letter';
    } else if (!RegExp(r'.*[0-9].*').hasMatch(value)) {
      return 'At least one digit';
    } else if (!RegExp(r'.*[!@#\$&*~].*').hasMatch(value)) {
      return 'At least one special character';
    }
    return null;
  }
}

class DentalSignup extends StatefulWidget {
  @override
  _DentalSignupState createState() => _DentalSignupState();
}

class _DentalSignupState extends State<DentalSignup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _institutionController = TextEditingController();
  String _selectedGender = 'Male';
  String _selectedCurrentStatus = 'Undergraduate Dental Student';

  String _phoneNumber = '';
  String _selectedCountryCode = 'US';
  String? _emailError;
  String? _passwordError;
  String _whatsappNumber = '';
  String _selected2CountryCode = 'US';
  String _alternativeNumber = '';
  String _selected3CountryCode = 'US';
  String _selectedCurrentCountry = '';
  String _selectedGraduationCountry = '';
  String _degreeAwardingBody = '';
  List<int> years = List<int>.generate(25, (index) => index + 2006);
  int _selectedYear = DateTime.now().year;

  File? _photoIdFile;
  File? _addressProofFile;
  File? _currentStatusProofFile;
  File? _professionalRegistrationFile;
  File? _otherDocumentFile;

  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _enableScreenshotRestriction(); // Add this line
  }

  Future<void> _enableScreenshotRestriction() async {
    if (Platform.isAndroid) {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  @override
  void dispose() {
    _disableScreenshotRestriction(); // Add this line

    super.dispose();
  }

  Future<void> _disableScreenshotRestriction() async {
    if (Platform.isAndroid) {
      await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  Future<void> _pickFile(Function(File) onFilePicked) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      onFilePicked(File(result.files.single.path!));
    }
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text;
      final String password = _passwordController.text;
      final String fullName = _fullNameController.text;
      final String institution = _institutionController.text;
      final String phoneNumber = _phoneNumber;
      final String whatsappNumber = _whatsappNumber;
      final String alternativeNumber = _alternativeNumber;

      if (password != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Passwords don't match"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loader
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text("Signing up..."),
                ],
              ),
            ),
          );
        },
      );

      try {
        var uri = Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/users/dental/signup/');

        var request = http.MultipartRequest('POST', uri);

        // Add text fields
        request.fields['email'] = email;
        request.fields['password'] = password;
        request.fields['full_name'] = fullName;
        request.fields['gender'] = _selectedGender;
        request.fields['current_status'] = _selectedCurrentStatus;
        request.fields['phone_number'] = phoneNumber;
        request.fields['whatsapp_number'] = whatsappNumber;
        request.fields['alternative_contact_number'] = alternativeNumber;
        request.fields['institution_practice'] = institution;
        request.fields['degree_awarding_body'] = _degreeAwardingBody;
        request.fields['expected_year_of_graduation'] =
            _selectedYear.toString();
        request.fields['current_country'] = _selectedCurrentCountry;
        request.fields['country_of_graduation'] = _selectedGraduationCountry;

        // Add files (if selected)
        if (_photoIdFile != null) {
          request.files.add(await http.MultipartFile.fromPath(
              'photo_id', _photoIdFile!.path));
        }
        if (_addressProofFile != null) {
          request.files.add(await http.MultipartFile.fromPath(
              'address_proof', _addressProofFile!.path));
        }
        if (_currentStatusProofFile != null) {
          request.files.add(await http.MultipartFile.fromPath(
              'current_status_proof', _currentStatusProofFile!.path));
        }
        if (_professionalRegistrationFile != null) {
          request.files.add(await http.MultipartFile.fromPath(
              'professional_registration_proof',
              _professionalRegistrationFile!.path));
        }
        if (_otherDocumentFile != null) {
          request.files.add(await http.MultipartFile.fromPath(
              'other_document', _otherDocumentFile!.path));
        }

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        Navigator.of(context).pop(); // Hide loader

        if (response.statusCode == 201) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DentalProfileApproval(),
            ),
          );
        } else {
          final responseBody = json.decode(response.body);
          String errorMessage = 'Failed to signup. Please try again later.';

          if (responseBody is Map && responseBody.containsKey('email')) {
            errorMessage = responseBody['email'][0];
          } else if (responseBody is Map &&
              responseBody.containsKey('non_field_errors')) {
            errorMessage = responseBody['non_field_errors'][0];
          }

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Signup Failed"),
                content: Text(errorMessage),
                actions: <Widget>[
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } catch (error) {
        Navigator.of(context).pop(); // Hide loader
        print('Signup failed with error: $error');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Signup Failed"),
              content: Text("Failed to signup. Please try again later."),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double fem = 1.0;
    double ffem = 1.0;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Color(0xff385a92),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Top Image
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Center(
                            child: Container(
                              width: 150 * fem,
                              height: 200 * fem,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15 * fem),
                                child: Image.asset(
                                  'assets/images/dentalportalclicked.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Entire White Section (scrollable with tabs and button)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(30)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, -2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Title
                              Text(
                                'SIGN UP',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 26 * ffem,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff385a92),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // TabBar
                              TabBar(
                                indicatorColor: Color(0xff385a92),
                                labelColor: Color(0xff385a92),
                                unselectedLabelColor: Colors.grey,
                                labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                tabs: const [
                                  Tab(text: "Basic"),
                                  Tab(text: "Contact"),
                                  Tab(text: "Education"),
                                  Tab(text: "Docs"),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Tab Views
                              Container(
                                height:
                                    500, // Just enough to scroll inside tabs
                                child: TabBarView(
                                  children: [
                                    _tabWrapper(buildBasicInfoTab()),
                                    _tabWrapper(buildContactTab()),
                                    _tabWrapper(buildEducationTab()),
                                    _tabWrapper(buildDocumentsTab()),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Sign Up Button
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 12),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _handleSignup,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xff385a92),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// A wrapper to make each tab scrollable with padding
  Widget _tabWrapper(Widget child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Form(
        key: _formKey,
        child: child,
      ),
    );
  }

  Widget buildBasicInfoTab() {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          decoration: _buildInputDecoration('Email Address', Icons.email),
          keyboardType: TextInputType.emailAddress,
          validator: EmailValidator.validate,
        ),
        if (_emailError != null)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(_emailError!, style: TextStyle(color: Colors.red)),
          ),
        SizedBox(height: 20),
        TextFormField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          decoration: _buildPasswordInputDecoration('Password'),
          validator: PasswordValidator.validate,
        ),
        if (_passwordError != null)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(_passwordError!, style: TextStyle(color: Colors.red)),
          ),
        SizedBox(height: 20),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_passwordVisible,
          decoration: _buildInputDecoration('Confirm Password', Icons.lock),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            } else if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
        SizedBox(height: 20),
        TextFormField(
          controller: _fullNameController,
          decoration: _buildInputDecoration('Full Name', Icons.person),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                onChanged: (val) => setState(() => _selectedGender = val!),
                items: ['Male', 'Female', 'Other']
                    .map(
                        (val) => DropdownMenuItem(value: val, child: Text(val)))
                    .toList(),
                decoration: _buildDropdownDecoration('Gender'),
              ),
            ),
            _infoIcon('Gender', 'Please select your gender.'),
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCurrentStatus,
                onChanged: (val) =>
                    setState(() => _selectedCurrentStatus = val!),
                items: [
                  'Undergraduate Dental Student',
                  'General Dentist',
                  'Postgraduate Dental Student',
                  'Specialist Dentist',
                  'Dental Therapist',
                  'Dental Hygienist',
                  'Dental Nurse',
                  'Dental Therapy Student',
                  'Dental Hygiene Student',
                  'Trainee Dental Nurse',
                ]
                    .map(
                        (val) => DropdownMenuItem(value: val, child: Text(val)))
                    .toList(),
                decoration: _buildDropdownDecoration('Your Current Status'),
              ),
            ),
            _infoIcon('Current Status',
                'This helps us verify your identity and tailor your experience.'),
          ],
        ),
      ],
    );
  }

  Widget buildContactTab() {
    return Column(
      children: [
        _buildPhoneInputField(
          'Phone Number',
          _selectedCountryCode,
          (number) {
            _phoneNumber = number?.phoneNumber ?? '';
            _selectedCountryCode = number?.isoCode ?? 'US';
          },
          'Phone Number',
          'At least one number is required. In case of no email access, we’ll contact you here.',
        ),
        _buildPhoneInputField(
          'WhatsApp Number',
          _selected2CountryCode,
          (number) {
            _whatsappNumber = number?.phoneNumber ?? '';
            _selected2CountryCode = number?.isoCode ?? 'US';
          },
          'WhatsApp Number',
          'We’ll send a verification message from +923078623100 or +447956646619.',
        ),
        _buildPhoneInputField(
          'Alternative Contact Number',
          _selected3CountryCode,
          (number) {
            _alternativeNumber = number?.phoneNumber ?? '';
            _selected3CountryCode = number?.isoCode ?? 'US';
          },
          'Alternative Number',
          'You can reuse your phone or WhatsApp number here if needed.',
        ),
      ],
    );
  }

  Widget buildEducationTab() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _institutionController,
                decoration: _buildInputDecoration(
                    'Institution/Practice Name', Icons.school),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your institution';
                  }
                  return null;
                },
              ),
            ),
            _infoIcon(
              'Institution or Practice',
              'Make sure this matches your documents. You can update it later.',
            ),
          ],
        ),
        SizedBox(height: 20),
        _buildCountryPicker(
          label: 'Select Current Country',
          selectedValue: _selectedCurrentCountry,
          onTap: () => _showCountryPickerDialog(true),
        ),
        SizedBox(height: 20),
        _buildCountryPicker(
          label: 'Select Country of Graduation',
          selectedValue: _selectedGraduationCountry,
          onTap: () => _showCountryPickerDialog(false),
        ),
        SizedBox(height: 20),
        DropdownButtonFormField<int>(
          value: _selectedYear,
          onChanged: (val) => setState(() => _selectedYear = val!),
          items: years
              .map((year) =>
                  DropdownMenuItem(value: year, child: Text(year.toString())))
              .toList(),
          decoration: _buildDropdownDecoration('Graduation Year'),
        ),
        SizedBox(height: 20),
        TextFormField(
          onChanged: (val) => _degreeAwardingBody = val,
          decoration:
              _buildInputDecoration('Degree Awarding Body', Icons.school),
        ),
      ],
    );
  }

  Widget buildDocumentsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Upload Required Documents",
            style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        _uploadField(
            "Photo ID", _photoIdFile, (f) => setState(() => _photoIdFile = f)),
        _uploadField("Address Proof", _addressProofFile,
            (f) => setState(() => _addressProofFile = f)),
        _uploadField("Proof of Current Status", _currentStatusProofFile,
            (f) => setState(() => _currentStatusProofFile = f)),
        _uploadField(
            "Professional Registration Proof",
            _professionalRegistrationFile,
            (f) => setState(() => _professionalRegistrationFile = f)),
        _uploadField("Other Document", _otherDocumentFile,
            (f) => setState(() => _otherDocumentFile = f)),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Color(0xff385a92)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      prefixIcon: Icon(icon, color: Color(0xff385a92)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Color(0xff385a92), width: 2.0),
      ),
    );
  }

  InputDecoration _buildPasswordInputDecoration(String label) {
    return _buildInputDecoration(label, Icons.lock).copyWith(
      suffixIcon: IconButton(
        icon: Icon(
          _passwordVisible ? Icons.visibility : Icons.visibility_off,
          color: Color(0xff385a92),
        ),
        onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
      ),
    );
  }

  InputDecoration _buildDropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Color(0xff385a92)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Color(0xff385a92), width: 2.0),
      ),
    );
  }

  Widget _infoIcon(String title, String message) {
    return IconButton(
      icon: Icon(Icons.help_outline, color: Color(0xff385a92)),
      onPressed: () => _showInfoDialog(title, message),
    );
  }

  Widget _buildCountryPicker({
    required String label,
    required String selectedValue,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(text: selectedValue),
          decoration: InputDecoration(
            labelText:
                selectedValue.isEmpty ? label : 'Selected: $selectedValue',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.arrow_drop_down),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInputField(
    String label,
    String initialCode,
    Function(PhoneNumber?) onChanged,
    String infoTitle,
    String infoMessage,
  ) {
    return Row(
      children: [
        Expanded(
          child: InternationalPhoneNumberInput(
            onInputChanged: onChanged,
            selectorConfig: SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET),
            autoValidateMode: AutovalidateMode.onUserInteraction,
            inputDecoration: _buildInputDecoration(label, Icons.phone),
            initialValue: PhoneNumber(isoCode: initialCode),
          ),
        ),
        _infoIcon(infoTitle, infoMessage),
      ],
    );
  }

  void _showCountryPickerDialog(bool isCurrentCountry) {
    showCountryPicker(
      context: context,
      onSelect: (Country country) {
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

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _uploadField(
      String label, File? selectedFile, Function(File) onFilePicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickFile(onFilePicked),
              icon: Icon(Icons.attach_file),
              label: Text("Upload $label"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff385a92),
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                selectedFile != null
                    ? selectedFile.path.split('/').last
                    : 'No file selected',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
