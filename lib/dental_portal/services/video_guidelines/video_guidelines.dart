import 'package:dental_key/dental_portal/mainscreen/dentalportal_main.dart';
import 'package:dental_key/dental_portal/services/BDS_World/BDS_World.dart';
import 'package:dental_key/dental_portal/services/career_pathways/career_pathways_homepage.dart';
import 'package:dental_key/dental_portal/services/display_dental_clinic/Display_dental_clinic.dart';
import 'package:dental_key/dental_portal/services/ips_books/IPS_Books.dart';
import 'package:dental_key/dental_portal/services/ug_exams_tests/01_tests_homepage.dart';
import 'package:dental_key/dental_portal/services/ug_helping_material/UG_helping_material.dart';
import 'package:dental_key/dental_portal/services/make_appointment_with_Rehan/appointments_withdr_rehan.dart';
import 'package:dental_key/dental_portal/services/foreign_exams/foreign_mockexams.dart';
import 'package:dental_key/dental_portal/services/dental_key_library/01_dkl_homepage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class videoguidelines extends StatefulWidget {
  final String accessToken;
  videoguidelines({required this.accessToken});

  @override
  _videoguidelinesState createState() => _videoguidelinesState();
}

class _videoguidelinesState extends State<videoguidelines> {
  late List<dynamic> subjects = [];
  String? selectedSubject;
  late List<dynamic> categories = [];
  int _selectedIndex = 0;
  String searchQuery = '';
  bool isLoading = false;

  Future<void> fetchSubjects({List<String>? categoryIds}) async {
    setState(() {
      isLoading = true;
    });

    String url;
    if (categoryIds != null && categoryIds.isNotEmpty) {
      final idsQuery = categoryIds.map((id) => 'categoryID=$id').join('&');
      url =
          'https://dental-key-738b90a4d87a.herokuapp.com/video_guidelines/subjects/?$idsQuery';
    } else {
      url =
          'https://dental-key-738b90a4d87a.herokuapp.com/video_guidelines/subjects/';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        subjects = json.decode(response.body);
      });
      setState(() {
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load subjects');
    }
  }

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse(
        'https://dental-key-738b90a4d87a.herokuapp.com/video_guidelines/categories/'));
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  void initState() {
    fetchSubjects();
    fetchCategories();
    super.initState();
  }

  Future<void> refreshpage() async {
    await fetchCategories();
    await fetchSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refreshpage,
        child: Stack(
          children: [
            SingleChildScrollView(
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
                              'assets/images/multimedia.png',
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
                                // Navigate to the desired class, e.g., BottomNavigation
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
                                    builder: (context) => BDSWorld(
                                        accessToken: widget.accessToken)),
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
                              'assets/images/helping_material.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                            ),
                            () {
                              // Navigate to the desired class, e.g., BottomNavigation
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ugHelpingMaterial(
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
                                    builder: (context) =>
                                        appointmentswithdrrehan(
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
                      'DENTAL KEY THEATRE',
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
                        color: const Color.fromARGB(0, 255, 255,
                            255), // Changed background color to white
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color.fromARGB(255, 255, 255, 255)),
                      ),
                      child: const Text(
                        'Explore our collection of instructional videos, offering step-by-step guidance on dental procedures and techniques',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black, // Set text color to black
                        ),
                        textAlign: TextAlign.justify, // Align text edge to edge
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Search',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: _buildAllSubjectsList()),
                ],
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: categories.length >= 2
          ? BottomNavigationBar(
              items: _buildBottomNavBarItems(),
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            )
          : null,
    );
  }

  Widget _buildAllSubjectsList() {
    List<dynamic> filteredSubjects = subjects.where((subject) {
      bool subjectMatch =
          subject['name'].toString().toLowerCase().contains(searchQuery);
      bool linkMatch = subject['links'].any((link) =>
          link['name'].toString().toLowerCase().contains(searchQuery));
      return subjectMatch || linkMatch;
    }).toList();

    return Column(
      children: filteredSubjects.map<Widget>((subject) {
        return Container(
          margin: EdgeInsets.only(bottom: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              ListView.builder(
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
                          child: Icon(
                            FontAwesomeIcons.youtube,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () {
                        launch(link['link_address']);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<BottomNavigationBarItem> _buildBottomNavBarItems() {
    List<BottomNavigationBarItem> items = [];

    items.add(BottomNavigationBarItem(
      icon: Icon(Icons.category),
      label: "All",
    ));

    items.addAll(categories.map((category) {
      return BottomNavigationBarItem(
        icon: Icon(Icons.category),
        label: category['name'],
      );
    }).toList());

    return items;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      fetchSubjects();
    } else {
      String selectedCategoryId = categories[index - 1]['id'];
      fetchSubjects(categoryIds: [selectedCategoryId]);
    }
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
