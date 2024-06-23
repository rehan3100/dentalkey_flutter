import 'package:dental_key/dental_portal/mainscreen/dentalportal_main.dart';
import 'package:dental_key/dental_portal/services/BDS_World/BDS_World.dart';
import 'package:dental_key/dental_portal/services/career_pathways/career_pathways_homepage.dart';
import 'package:dental_key/dental_portal/services/display_dental_clinic/Display_dental_clinic.dart';
import 'package:dental_key/dental_portal/services/ips_books/IPS_Books.dart';
import 'package:dental_key/dental_portal/services/ug_exams_tests/01_tests_homepage.dart';
import 'package:dental_key/dental_portal/services/make_appointment_with_Rehan/appointments_withdr_rehan.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dental_key/dental_portal/services/foreign_exams/foreign_mockexams.dart';
import 'package:dental_key/dental_portal/services/dental_key_library/01_dkl_homepage.dart';
import 'package:dental_key/dental_portal/services/video_guidelines/video_guidelines.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ugHelpingMaterial extends StatefulWidget {
  final String accessToken;
  ugHelpingMaterial({required this.accessToken});

  @override
  _ugHelpingMaterialState createState() => _ugHelpingMaterialState();
}

class _ugHelpingMaterialState extends State<ugHelpingMaterial> {
  late List<dynamic> subjects = [];
  String? selectedSubject;

  Future<void> fetchSubjects() async {
    final response = await http.get(Uri.parse(
        'https://dental-key-738b90a4d87a.herokuapp.com/ug_material/subjects/'));
    if (response.statusCode == 200) {
      setState(() {
        subjects = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load subjects');
    }
  }

  @override
  void initState() {
    fetchSubjects();
    selectedSubject = "Show All Subjects";
    super.initState();
  }

  Future<void> refreshpage() async {
    await fetchSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refreshpage,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Container 1: containing asset image
              Container(
                width: 150,
                height: 300,
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  color: Color(0xFF385A92),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/helping_material.png',
                          width: 150,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(
                color: Colors.white,
                thickness: 3.0,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DentalPortalMain(
                                    accessToken: widget.accessToken),
                              ),
                            );
                          },
                          child: const Row(
                            children: [
                              Icon(
                                Icons.arrow_back,
                                size: 30,
                                color: Colors.black,
                              ),
                              Icon(
                                Icons.home,
                                size: 30,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      _buildContainer(
                        Image.asset(
                          'assets/images/BDS_World_logo.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        () {
                          // Navigate to the desired class, e.g., BottomNavigation
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    BDSWorld(accessToken: widget.accessToken)),
                          );
                        },
                      ),
                      SizedBox(width: 20),
                      _buildContainer(
                        Image.asset(
                          'assets/images/ips_logo.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        () {
                          // Navigate to the desired class, e.g., BottomNavigation
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    IPS(accessToken: widget.accessToken)),
                          );
                        },
                      ),
                      SizedBox(width: 20),
                      _buildContainer(
                        Image.asset(
                          'assets/images/career_options.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        () {
                          // Navigate to the desired class, e.g., BottomNavigation
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DentalCareerPathways(
                                    accessToken: widget.accessToken)),
                          );
                        },
                      ),
                      SizedBox(width: 20),
                      _buildContainer(
                        Image.asset(
                          'assets/images/mock_exams.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        () {
                          // Navigate to the desired class, e.g., BottomNavigation
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForeignMockExam(
                                    accessToken: widget.accessToken)),
                          );
                        },
                      ),
                      SizedBox(width: 20),
                      _buildContainer(
                        Image.asset(
                          'assets/images/UGTests.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        () {
                          // Navigate to the desired class, e.g., BottomNavigation
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ugTestsExams(
                                    accessToken: widget.accessToken)),
                          );
                        },
                      ),
                      SizedBox(width: 20),
                      _buildContainer(
                        Image.asset(
                          'assets/images/free_books.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        () {
                          // Navigate to the desired class, e.g., BottomNavigation
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DKLlibrary(
                                    accessToken: widget.accessToken)),
                          );
                        },
                      ),
                      SizedBox(width: 20),
                      _buildContainer(
                        Image.asset(
                          'assets/images/multimedia.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        () {
                          // Navigate to the desired class, e.g., BottomNavigation
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => videoguidelines(
                                    accessToken: widget.accessToken)),
                          );
                        },
                      ),
                      SizedBox(width: 20),
                      _buildContainer(
                        Image.asset(
                          'assets/images/dental_unit.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        () {
                          // Navigate to the desired class, e.g., BottomNavigation
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => displayDentalClinic(
                                    accessToken: widget.accessToken)),
                          );
                        },
                      ),
                      SizedBox(width: 20),
                      _buildContainer(
                        Image.asset(
                          'assets/images/rehanappointment.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        () {
                          // Navigate to the desired class, e.g., BottomNavigation
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => appointmentswithdrrehan(
                                    accessToken: widget.accessToken)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 20),
                child: Container(
                  width: 150,
                  height: 1,
                  color: Colors.black, // Color of the line
                ),
              ),
              const Center(
                child: Text(
                  'UNDERGRADUATE HELPING MATERIAL',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    decoration: TextDecoration.underline, // Underline text
                  ),
                  textAlign: TextAlign.center, // Align text centrally
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                        0, 255, 255, 255), // Changed background color to white
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color.fromARGB(255, 255, 255, 255)),
                  ),
                  child: const Text(
                    'Unlock a treasure trove of resources tailored for dental undergraduates. From study guides to reference materials, everything you need to excel in your studies is right here.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black, // Set text color to black
                    ),
                    textAlign: TextAlign.justify, // Align text edge to edge
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10, right: 5, left: 5),
                child: Container(
                  padding: EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton<String>(
                              value: selectedSubject,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedSubject = newValue;
                                });
                              },
                              items: _buildDropdownItems(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              selectedSubject == "Show All Subjects"
                  ? _buildAllSubjectsList()
                  : _buildSubjectList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectList() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              subjects.firstWhere(
                                  (s) => s['name'] == selectedSubject)['image'],

                              width: double.infinity,
                              fit: BoxFit.cover,
                              height:
                                  150, // Adjust the value to change the height of the image
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(8.0),
                              color: Colors.black54,
                              child: Text(
                                // Use a null check operator to handle missing name
                                subjects.firstWhere((s) =>
                                    s['name'] == selectedSubject)['name'],

                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
              Padding(
                padding: EdgeInsets.only(left: 8.0, right: 8.0),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: subjects
                      .firstWhere((s) => s['name'] == selectedSubject)['links']
                      .length,
                  itemBuilder: (BuildContext context, int i) {
                    final link = subjects.firstWhere(
                        (s) => s['name'] == selectedSubject)['links'][i];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          '${link['name']}',
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
                              '${link['description']}',
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
                            child: _getIcon(link['link_nature']),
                          ),
                        ),
                        onTap: () {
                          launch(link['link_address']);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllSubjectsList() {
    return Column(
      children: subjects.map<Widget>((subject) {
        return Container(
          margin: EdgeInsets.only(bottom: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              '${subject['image']}',
                              width: double.infinity,
                              fit: BoxFit.cover,
                              height:
                                  150, // Adjust the value to change the height of the image
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(8.0),
                              color: Colors.black54,
                              child: Text(
                                '${subject['name']}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
              Padding(
                padding: EdgeInsets.only(left: 8.0, right: 8.0),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: subject['links'].length,
                  itemBuilder: (BuildContext context, int i) {
                    final link = subject['links'][i];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          '${link['name']}',
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
                              '${link['description']}',
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
                            child: _getIcon(link['link_nature']),
                          ),
                        ),
                        onTap: () {
                          launch(link['link_address']);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Icon _getIcon(String linkNature) {
    switch (linkNature) {
      case 'Facebook':
        return Icon(FontAwesomeIcons.facebook,
            color: const Color.fromARGB(255, 255, 255, 255));
      case 'WhatsApp':
        return Icon(FontAwesomeIcons.whatsapp, color: Colors.white);
      case 'Instagram':
        return Icon(FontAwesomeIcons.instagram, color: Colors.white);
      case 'Twitter':
        return Icon(FontAwesomeIcons.twitter, color: Colors.white);
      case 'LinkedIn':
        return Icon(FontAwesomeIcons.linkedin, color: Colors.white);
      case 'Pinterest':
        return Icon(FontAwesomeIcons.pinterest, color: Colors.white);
      case 'YouTube':
        return Icon(FontAwesomeIcons.youtube, color: Colors.white);
      case 'Telegram':
        return Icon(FontAwesomeIcons.telegram, color: Colors.white);
      case 'Google Drive':
        return Icon(FontAwesomeIcons.googleDrive, color: Colors.white);
      case 'Dropbox':
        return Icon(FontAwesomeIcons.dropbox, color: Colors.white);
      case 'OneDrive':
        return Icon(FontAwesomeIcons.microsoft, color: Colors.white);
      case 'Website':
        return Icon(FontAwesomeIcons.globe, color: Colors.white);

      default:
        return Icon(FontAwesomeIcons.link);
    }
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    List<DropdownMenuItem<String>> items = [];

    items.add(DropdownMenuItem<String>(
      value: "Show All Subjects",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text('Show All Subjects'),
      ),
    ));

    items.addAll(subjects.map<DropdownMenuItem<String>>(
      (dynamic subject) {
        return DropdownMenuItem<String>(
          value: subject['name'],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(subject['name']),
          ),
        );
      },
    ));

    return items;
  }

  Widget _buildContainer(Widget child, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // Pass the onTap function to GestureDetector
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black),
        ),
        padding: EdgeInsets.all(8),
        child: child,
      ),
    );
  }
}
