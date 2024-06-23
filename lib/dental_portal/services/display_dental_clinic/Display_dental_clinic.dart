import 'package:dental_key/dental_portal/mainscreen/dentalportal_main.dart';
import 'package:dental_key/dental_portal/services/BDS_World/BDS_World.dart';
import 'package:dental_key/dental_portal/services/career_pathways/career_pathways_homepage.dart';
import 'package:dental_key/dental_portal/services/ips_books/IPS_Books.dart';
import 'package:dental_key/dental_portal/services/ug_exams_tests/01_tests_homepage.dart';
import 'package:dental_key/dental_portal/services/ug_helping_material/UG_helping_material.dart';
import 'package:dental_key/dental_portal/services/make_appointment_with_Rehan/appointments_withdr_rehan.dart';

import 'package:dental_key/dental_portal/services/foreign_exams/foreign_mockexams.dart';
import 'package:dental_key/dental_portal/services/dental_key_library/01_dkl_homepage.dart';
import 'package:dental_key/dental_portal/services/video_guidelines/video_guidelines.dart';
import 'package:flutter/material.dart';

class displayDentalClinic extends StatelessWidget {
  final String accessToken;
  displayDentalClinic({required this.accessToken});

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
                        'assets/images/dental_unit.png',
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
                                  BDSWorld(accessToken: accessToken)),
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
                  'DISPLAY YOUR DENTAL CLINIC',
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
              padding: EdgeInsets.only(bottom: 30),
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                      0, 255, 255, 255), // Changed background color to white
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color.fromARGB(255, 255, 255, 255)),
                ),
                child: Text(
                  'We will update this app soon to have a function of displaying your dental clinics.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black, // Set text color to black
                  ),
                  textAlign: TextAlign.justify, // Align text edge to edge
                ),
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
