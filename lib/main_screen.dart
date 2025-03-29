import 'package:dental_key/marketplace/marketplace_main.dart';
import 'package:dental_key/non_clinical_prof/signup.dart';
import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'package:dental_key/dental_portal/authentication/login_dental.dart';
import 'package:dental_key/patient_portal/authentication/login_patient.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String selectedPortal = '';

  Widget portalCard(String title, String assetClicked, String assetUnclicked) {
    bool isSelected = selectedPortal == title;
    return Expanded(
      child: Card(
        elevation: isSelected ? 10 : 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          onTap: () {
            setState(() {
              selectedPortal = title;
            });
          },
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Image.asset(
                  isSelected ? assetClicked : assetUnclicked,
                  height: 70,
                ),
                SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.blue : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SplashScreen()),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 80, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', width: 180, height: 160),
                SizedBox(height: 20),
                Text(
                  'Select Your Portal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 30),
                Row(children: [
                  portalCard(
                      'Clinical Professionals',
                      'assets/images/clinical_dental_professional_portal_clicked.png',
                      'assets/images/clinical_dental_professional_portal_unclicked.png'),
                  portalCard(
                      'Non-Clinical Professionals',
                      'assets/images/non_clinical_dental_professional_portal_clicked.png',
                      'assets/images/non_clinical_dental_professional_portal_unclicked.png'),
                ]),
                Row(children: [
                  portalCard(
                      'Patient Portal',
                      'assets/images/patient_portal_clicked.png',
                      'assets/images/patient_portal_unclicked.png'),
                  portalCard(
                      'Marketplace',
                      'assets/images/marketplace_clicked.png',
                      'assets/images/marketplace_unclicked.png'),
                ]),
                SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                  onPressed: selectedPortal.isEmpty
                      ? null
                      : () {
                          if (selectedPortal == 'Clinical Professionals') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginDental()),
                            );
                          } else if (selectedPortal ==
                              'Non-Clinical Professionals') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      NonClinicalSignupScreen()),
                            );
                          } else if (selectedPortal == 'Patient Portal') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPatient()),
                            );
                          } else if (selectedPortal == 'Marketplace') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MarketplaceSelectionScreen()),
                            );
                          }
                        },
                  child: Text(
                    selectedPortal.isEmpty
                        ? 'Select Portal to Continue'
                        : 'Continue to $selectedPortal',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
