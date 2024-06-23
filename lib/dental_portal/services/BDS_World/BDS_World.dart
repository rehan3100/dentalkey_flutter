import 'package:dental_key/dental_portal/mainscreen/dentalportal_main.dart';
import 'package:dental_key/dental_portal/services/career_pathways/career_pathways_homepage.dart';
import 'package:dental_key/dental_portal/services/display_dental_clinic/Display_dental_clinic.dart';
import 'package:dental_key/dental_portal/services/ips_books/IPS_Books.dart';
import 'package:dental_key/dental_portal/services/ug_exams_tests/01_tests_homepage.dart';
import 'package:dental_key/dental_portal/services/ug_helping_material/UG_helping_material.dart';
import 'package:dental_key/dental_portal/services/make_appointment_with_Rehan/appointments_withdr_rehan.dart';
import 'package:dental_key/dental_portal/services/foreign_exams/foreign_mockexams.dart';
import 'package:dental_key/dental_portal/services/dental_key_library/01_dkl_homepage.dart';
import 'package:dental_key/dental_portal/services/video_guidelines/video_guidelines.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http; // Import for HTTP requests
import 'dart:convert'; // Import for JSON handling

class BDSWorld extends StatefulWidget {
  final String accessToken;

  BDSWorld({required this.accessToken});

  @override
  _BDSWorldState createState() => _BDSWorldState(accessToken: accessToken);
}

class _BDSWorldState extends State<BDSWorld> {
  final String accessToken;
  _BDSWorldState({required this.accessToken});

  late Future<List<Group>> futureGroups;
  TextEditingController _searchController = TextEditingController();
  String _searchString = "";

  @override
  void initState() {
    super.initState();
    futureGroups = GroupService(accessToken: accessToken).fetchGroups();
    _searchController.addListener(() {
      setState(() {
        _searchString = _searchController.text;
      });
    });
  }

  void _launchUrl(String url) async {
    final String encodedUrl = Uri.encodeFull(url);
    if (await canLaunch(encodedUrl)) {
      await launch(encodedUrl);
    } else {
      throw 'Could not launch $encodedUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                        'assets/images/BDS_World_logo.png',
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
                              builder: (context) =>
                                  DentalPortalMain(accessToken: accessToken),
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
                                  IPS(accessToken: accessToken)),
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
                                  accessToken: accessToken)),
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
                              builder: (context) =>
                                  ForeignMockExam(accessToken: accessToken)),
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
                              builder: (context) =>
                                  ugTestsExams(accessToken: accessToken)),
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
                              builder: (context) =>
                                  ugHelpingMaterial(accessToken: accessToken)),
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
                              builder: (context) =>
                                  DKLlibrary(accessToken: accessToken)),
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
                              builder: (context) =>
                                  videoguidelines(accessToken: accessToken)),
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
                                  accessToken: accessToken)),
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
                                  accessToken: accessToken)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 30.0, bottom: 20),
              child: Container(
                width: 150,
                height: 1,
                color: Colors.black, // Color of the line
              ),
            ),
            Container(
              child: Center(
                child: Text(
                  'BDS WORLD',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    decoration: TextDecoration.underline, // Underline text
                  ),
                  textAlign: TextAlign.center, // Align text centrally
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 0),
              child: Container(
                padding: EdgeInsets.only(right: 16, left: 16, top: 16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                      0, 255, 255, 255), // Changed background color to white
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color.fromARGB(255, 255, 255, 255)),
                ),
                child: Text(
                  'Join vibrant communities of dental students and professionals from around the globe. Connect, collaborate, and share knowledge with peers in the dynamic world of dentistry, enhancing your learning experience and expanding your professional network. Request group of your Choice, if you are unsure confirm your group from Dr. Muhammad Rehan. You\'ll only be added after verification of your details',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black, // Set text color to black
                  ),
                  textAlign: TextAlign.justify, // Align text edge to edge
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Groups',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 15, left: 15),
              child: FutureBuilder<List<Group>>(
                future: futureGroups,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No groups available'));
                  } else {
                    List<Group> filteredGroups = snapshot.data!.where((group) {
                      return group.name
                          .toLowerCase()
                          .contains(_searchString.toLowerCase());
                    }).toList();

                    if (filteredGroups.isEmpty) {
                      return Center(child: Text('No groups found'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filteredGroups.length,
                      itemBuilder: (context, index) {
                        final group = filteredGroups[index];
                        return GestureDetector(
                          onTap: () {
                            _launchUrl(group.linkAddress);
                          },
                          child: Card(
                            margin: EdgeInsets.only(bottom: 20.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 5,
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: Image.network(
                                      group.imageUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          group.name,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5.0),
                                        Text(
                                          group.description,
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14.0,
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
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
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

class GroupService {
  final String accessToken;

  GroupService({required this.accessToken});

  Future<List<Group>> fetchGroups() async {
    final response = await http.get(
      Uri.parse(
          'https://dental-key-738b90a4d87a.herokuapp.com/miscellaneous/groups/'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((group) => Group.fromJson(group)).toList();
    } else {
      throw Exception('Failed to load groups');
    }
  }
}

class Group {
  final String id;
  final String name;
  final String linkAddress;
  final String description;
  final String imageUrl;

  Group({
    required this.id,
    required this.name,
    required this.linkAddress,
    required this.description,
    required this.imageUrl,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      linkAddress: json['link_address'],
      description: json['description'],
      imageUrl: json['image'],
    );
  }
}
