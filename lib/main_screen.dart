import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'package:dental_key/dental_portal/authentication/login_dental.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isDentistPortalClicked = false;
  bool isDentalDoctorClicked = false;
  bool isPatientPortalClicked = false;
  bool isPatientPatientClicked = false;

  void handleGroup1Click() {
    setState(() {
      isDentistPortalClicked = !isDentistPortalClicked;
      if (isDentistPortalClicked) {
        isDentalDoctorClicked = true;
        isPatientPortalClicked = false;
        isPatientPatientClicked = false;
      } else {
        isDentalDoctorClicked = false;
      }
    });
  }

  void handleGroup2Click() {
    setState(() {
      isPatientPortalClicked = !isPatientPortalClicked;
      if (isPatientPortalClicked) {
        isPatientPatientClicked = true;
        isDentistPortalClicked = false;
        isDentalDoctorClicked = false;
      } else {
        isPatientPatientClicked = false;
      }
    });
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
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  14.0, // left padding
                  100.0, // top padding
                  14.0, // right padding
                  20.0), // bottom padding (adjust as needed)
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 52.0),
                    width: 220.0,
                    height: 200.0,
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    'CHOOSE AN OPTION',
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontFamily: 'Inter',
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      height: 3.0,
                      letterSpacing: -0.24,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: handleGroup1Click,
                          child: AspectRatio(
                            aspectRatio:
                                1.0, // Adjust this ratio as needed to maintain the desired height
                            child: Image.asset(
                              isDentistPortalClicked
                                  ? 'assets/images/dentalportal_clicked.png'
                                  : 'assets/images/dentalportal_unclicked.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: handleGroup2Click,
                          child: AspectRatio(
                            aspectRatio:
                                1.0, // Adjust this ratio as needed to maintain the desired height
                            child: Image.asset(
                              isPatientPortalClicked
                                  ? 'assets/images/patientportal_clicked.png'
                                  : 'assets/images/patientportal_unclicked.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isDentistPortalClicked && isDentalDoctorClicked)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginDental(),
                        ),
                      );
                    },
                    child: Text('Continue to Login'),
                  ),
                if (isPatientPortalClicked && isPatientPatientClicked)
                  Expanded(
                    child: Text(
                        'Right now, we are not accepting Patient Portal registrations. If you are a dentist or dental student you can register in Dentists Portal'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}