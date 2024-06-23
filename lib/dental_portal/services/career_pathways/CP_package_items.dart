import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'pdf_viewer_screen.dart';
import 'package:dental_key/dental_portal/services/dental_key_library/01_dkl_homepage.dart'
    as dkl_library;

class PackageDetailScreen extends StatefulWidget {
  final String packageId;
  final String accessToken;

  const PackageDetailScreen(
      {Key? key, required this.packageId, required this.accessToken})
      : super(key: key);

  @override
  _PackageDetailScreenState createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  bool isLoading = true;
  Map<String, dynamic> packageDetails = {};

  @override
  void initState() {
    super.initState();
    _fetchPackageDetails();
  }

  Future<void> _fetchPackageDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/career_pathways/package/${widget.packageId}/details/'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${widget.accessToken}',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          packageDetails = json.decode(response.body);
          isLoading = false;
        });
        print('Package details fetched successfully.');
        print('Package details: $packageDetails');
      } else {
        throw Exception('Failed to fetch package details');
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Package Details'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      packageDetails['package_name'] ?? '',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      packageDetails['package_description'] ?? '',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    if (packageDetails['notes'].isNotEmpty ||
                        packageDetails['schedules'].isNotEmpty)
                      _buildReferenceBooksCard(),
                    _buildNotesSection('Notes', packageDetails['notes'] ?? []),
                    _buildSchedulesSection(
                        'Schedules', packageDetails['schedules'] ?? []),
                    _buildVideoSection(
                        'Videos', packageDetails['videos'] ?? []),
                    _buildUniversitiesSection(
                        'Universities', packageDetails['universities'] ?? []),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildReferenceBooksCard() {
    return Card(
      color: Colors.lightBlueAccent,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          'Reference Books',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Go to Dental Key Library'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    dkl_library.DKLlibrary(accessToken: widget.accessToken)),
          );
        },
      ),
    );
  }

  Widget _buildNotesSection(String title, List<dynamic> notes) {
    if (notes.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return Card(
              color: index % 2 == 0 ? Colors.grey[25] : Colors.grey[200],
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading:
                    Icon(FontAwesomeIcons.solidFileAlt, color: Colors.blue),
                title: Text(
                  note['title'] ?? '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PDFViewerScreen(
                        pdfUrl: note['attachment'] ?? '',
                        title: note['title'] ?? '',
                        accessToken: widget.accessToken,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSchedulesSection(String title, List<dynamic> schedules) {
    if (schedules.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return Card(
              color: index % 2 == 0 ? Colors.grey[25] : Colors.grey[200],
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading:
                    Icon(FontAwesomeIcons.calendarAlt, color: Colors.green),
                title: Text(
                  schedule['title'] ?? '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PDFViewerScreen(
                        pdfUrl: schedule['attachment'] ?? '',
                        title: schedule['title'] ?? '',
                        accessToken: widget.accessToken,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildVideoSection(String title, List<dynamic> items) {
    if (items.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final video = items[index];
            return Card(
              color: index % 2 == 0 ? Colors.grey[25] : Colors.grey[200],
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              child: ListTile(
                title: Text(
                  '${video['name'] ?? ''}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Text(
                      '${video['description'] ?? ''}',
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 5),
                  ],
                ),
                trailing: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 0, 59, 96),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      FontAwesomeIcons.youtube,
                      color: Colors.white,
                    ),
                  ),
                ),
                onTap: () {
                  final url = video['link_address'];
                  if (url != null) {
                    launch(url);
                  }
                },
              ),
            );
          },
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildUniversitiesSection(String title, List<dynamic> universities) {
    if (universities.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: universities.length,
          itemBuilder: (context, index) {
            final university = universities[index];
            return Card(
              color: index % 2 == 0 ? Colors.grey[25] : Colors.grey[200],
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading:
                    Icon(FontAwesomeIcons.university, color: Colors.deepPurple),
                contentPadding: EdgeInsets.all(16),
                title: Text(
                  university['university_name'] ?? '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_city, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(university['city'] ?? ''),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.flag, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(university['country__country_name'] ?? ''),
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  final universityId = university['university_id'];
                  final universityName = university['university_name'];
                  final countryId = university['country__country_id'] ?? '';
                  print('countryId: $countryId'); // Add this line for debugging
                  if (universityId != null && universityId.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProgramsScreen(
                          universityId: universityId,
                          accessToken: widget.accessToken,
                          universityName: universityName,
                          countryId: countryId,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('University ID is missing')),
                    );
                  }
                },
              ),
            );
          },
        ),
        SizedBox(height: 16),
      ],
    );
  }
}

class ProgramsScreen extends StatelessWidget {
  final String universityId;
  final String accessToken;
  final String universityName;
  final String countryId;

  const ProgramsScreen({
    Key? key,
    required this.universityId,
    required this.accessToken,
    required this.universityName,
    required this.countryId,
  }) : super(key: key);

  Future<List<dynamic>> _fetchPrograms() async {
    final response = await http.get(
      Uri.parse(
          'https://dental-key-738b90a4d87a.herokuapp.com/career_pathways/universities/$universityId/programs/'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $accessToken',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load programs');
    }
  }

  void _showAdmissionDialog(
    BuildContext context,
    String programId,
    String universityId,
    String countryId,
    String programName,
    String universityName,
    String fee,
    String currency,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AdmissionDialog(
          programId: programId,
          universityId: universityId,
          countryId: countryId,
          programName: programName,
          universityName: universityName,
          fee: fee,
          currency: currency,
          accessToken: accessToken,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(universityName),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchPrograms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No programs found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final program = snapshot.data![index];
                return Card(
                  color: index % 2 == 0 ? Colors.grey[25] : Colors.grey[200],
                  margin: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          program['program_name'] ?? '',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(program['program_description'] ?? ''),
                        SizedBox(height: 8),
                        Text(
                            'Fee: ${program['currency']} ${program['program_fee']}'),
                        SizedBox(height: 8),
                        Text(
                            'Eligibility Criteria: ${program['admission_criteria'] ?? 'N/A'}'),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _showAdmissionDialog(
                              context,
                              program['program_id'] ?? '',
                              universityId,
                              countryId,
                              program['program_name'] ?? '',
                              universityName,
                              program['program_fee'] ?? '',
                              program['currency'] ?? '',
                            );
                          },
                          child: Text('Get admission'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class AdmissionDialog extends StatefulWidget {
  final String programId;
  final String universityId;
  final String countryId;
  final String programName;
  final String universityName;
  final String fee;
  final String currency;
  final String accessToken;

  const AdmissionDialog({
    Key? key,
    required this.programId,
    required this.universityId,
    required this.countryId,
    required this.programName,
    required this.universityName,
    required this.fee,
    required this.currency,
    required this.accessToken,
  }) : super(key: key);

  @override
  _AdmissionDialogState createState() => _AdmissionDialogState();
}

class _AdmissionDialogState extends State<AdmissionDialog> {
  bool _canPayFee = false;
  bool _manageVisaFee = false;
  bool _confirmAdmission = false;
  bool _readEligibilityCriteria = false;

  Future<void> _submitAdmission() async {
    try {
      final payloadBase64 = widget.accessToken.split('.')[1];
      final normalized = base64Url.normalize(payloadBase64);
      final payloadString = utf8.decode(base64Url.decode(normalized));
      final payload = json.decode(payloadString);
      final userId = payload['user_id'];

      final requestBody = {
        'user': userId,
        'program': widget.programId,
        'university': widget.universityId,
        'country': widget.countryId,
      };

      print('Request Body: $requestBody');

      final response = await http.post(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/career_pathways/admissions/'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${widget.accessToken}',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Admission confirmed')),
        );
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to confirm admission: $error')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Admission Confirmation'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            CheckboxListTile(
              title:
                  Text('I can pay a fee of ${widget.currency} ${widget.fee}'),
              value: _canPayFee,
              onChanged: (bool? value) {
                setState(() {
                  _canPayFee = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text("I'll be able to manage visa fee as well."),
              value: _manageVisaFee,
              onChanged: (bool? value) {
                setState(() {
                  _manageVisaFee = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text(
                  'I confirm I want to take admission in ${widget.programName} delivered by ${widget.universityName}.'),
              value: _confirmAdmission,
              onChanged: (bool? value) {
                setState(() {
                  _confirmAdmission = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text("I have read eligibility criteria and I'm eligible."),
              value: _readEligibilityCriteria,
              onChanged: (bool? value) {
                setState(() {
                  _readEligibilityCriteria = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Confirm'),
          onPressed: () {
            if (_canPayFee &&
                _manageVisaFee &&
                _confirmAdmission &&
                _readEligibilityCriteria) {
              _submitAdmission();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please complete all the checks')),
              );
            }
          },
        ),
      ],
    );
  }
}
