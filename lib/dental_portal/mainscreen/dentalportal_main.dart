import 'package:dental_key/dental_portal/mainscreen/dental-account.dart';
import 'package:dental_key/dental_portal/mainscreen/dental_notifications.dart';
import 'package:dental_key/dental_portal/mainscreen/chat_with_dr_Rehan.dart';
import 'package:dental_key/dental_portal/mainscreen/my_appointments.dart';
import 'package:dental_key/dental_portal/mainscreen/AID_team_members.dart';
import 'package:dental_key/dental_portal/services/BDS_World/BDS_World.dart';
import 'package:dental_key/dental_portal/services/career_pathways/career_pathways_homepage.dart';
import 'package:dental_key/dental_portal/services/clinical_case_discussion/case_discussion.dart';
import 'package:dental_key/dental_portal/services/dental_key_library/00_modal_dkl.dart';
import 'package:dental_key/dental_portal/services/display_dental_clinic/Display_dental_clinic.dart';
import 'package:dental_key/dental_portal/services/employment_history.dart';
import 'package:dental_key/dental_portal/services/ips_books/IPS_Books.dart';
import 'package:dental_key/dental_portal/services/pending_invitations.dart';
import 'package:dental_key/dental_portal/services/ug_exams_tests/01_tests_homepage.dart';
import 'package:dental_key/dental_portal/services/ug_helping_material/UG_helping_material.dart';
import 'package:dental_key/dental_portal/services/make_appointment_with_Rehan/appointments_withdr_rehan.dart';
import 'package:dental_key/dental_portal/services/foreign_exams/foreign_mockexams.dart';
import 'package:dental_key/dental_portal/services/video_guidelines/video_guidelines.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dental_key/dental_portal/authentication/login_dental.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences for token management
import 'package:provider/provider.dart';
import '../../unread_provider.dart'; // Correct the path to the provider
import '../../utils/utils.dart'; // Import the utility file
import '../../notification_provider.dart'; // Correct the path to the provider
import 'package:logging/logging.dart';

class DentalPortalMain extends StatefulWidget {
  final String accessToken;

  DentalPortalMain({
    required this.accessToken,
  });

  @override
  _DentalPortalMainState createState() =>
      _DentalPortalMainState(accessToken: accessToken);
}

class _DentalPortalMainState extends State<DentalPortalMain> {
  bool tapped = false;
  bool showRow = false;
  final String accessToken;
  bool isLoading = false;
  String? userEmail;
  final Logger _logger = Logger('DentalPortalMain'); // Initialize the logger

  _DentalPortalMainState({required this.accessToken});
  @override
  void initState() {
    super.initState();
    _fetchUserEmail(); // fetch user email first
    _refreshPage(); // then refresh unread counts
  }

  Future<void> _fetchUserEmail() async {
    print("🔄 Fetching user email using access token...");

    final response = await http.get(
      Uri.parse('https://dental-key-738b90a4d87a.herokuapp.com/users/details/'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print("📬 API Response Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("✅ Email fetched: ${data['email']}");

      setState(() {
        userEmail = data['email'];
      });
    } else {
      print("❌ Failed to load user email: ${response.body}");
    }
  }

  Future<void> _refreshPage() async {
    await fetchAndSetUnreadRequests(context, accessToken);
    await fetchAndSetUnreadNotifications(context, accessToken);
  }

  Future<void> fetchAndSetUnreadNotifications(
      BuildContext context, String accessToken) async {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    await notificationProvider.loadUnreadNotifications();
    await notificationProvider.fetchNotifications(accessToken);
  }

  @override
  Widget build(BuildContext context) {
    double fem = 1.0;
    final unreadIndices = Provider.of<UnreadProvider>(context).unreadIndices;
    final unreadNotificationIndices =
        Provider.of<NotificationProvider>(context).unreadNotificationIndices;
    _logger.info(
        'Unread notifications in DentalPortalMain: ${unreadNotificationIndices.length}');
    return WillPopScope(
      onWillPop: () async {
        return await _showLogoutConfirmationDialog(context) ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: <Widget>[
            Expanded(
              child: Center(
                child: IconButton(
                  iconSize: 30.0,
                  icon: Icon(Icons.group_add),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AIDTeamMembersPage(accessToken: accessToken)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Stack(
                  children: [
                    IconButton(
                      iconSize: 30.0,
                      icon: Icon(Icons.forum),
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                RehanChatPage(accessToken: accessToken)),
                      ),
                    ),
                    if (unreadIndices.isNotEmpty)
                      Positioned(
                        right: 0,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Text(
                            unreadIndices.length.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: IconButton(
                  iconSize: 30.0,
                  icon: Icon(Icons.calendar_month),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            myappointments(accessToken: accessToken)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Stack(
                  children: [
                    IconButton(
                      iconSize: 30.0,
                      icon: Icon(Icons.notifications),
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DentalNotificationPage(
                                accessToken: accessToken)),
                      ),
                    ),
                    if (unreadNotificationIndices.isNotEmpty)
                      Positioned(
                        right: 0,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Text(
                            unreadNotificationIndices.length.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: IconButton(
                  iconSize: 30.0,
                  icon: Icon(Icons.account_circle),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DentalAccount(
                              accessToken: accessToken,
                            )),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refreshPage,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 150 * fem,
                      height: 180 * fem,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        color: Color(0xFF385A92),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/dentalportalclicked.png',
                                width: 150,
                                height: 180,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    children: [
                      // ✅ Generate CV Card
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => Scaffold(
                                      appBar:
                                          AppBar(title: Text("Generate CV")),
                                      body: Center(
                                          child: Text(
                                              "CV Generator Coming Soon!")),
                                    )),
                          );
                        },
                        child: Card(
                          color: Colors.lightBlue.shade100,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(Icons.description,
                                    size: 40, color: Colors.blueAccent),
                                SizedBox(width: 16),
                                Text(
                                  "Generate Professional CV",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      // ✅ Jobs Portal Card
                      GestureDetector(
                        onTap: () {
                          if (userEmail != null && userEmail!.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmploymentHistoryScreen(
                                    userEmail: userEmail!),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("User email not loaded yet")),
                            );
                          }
                        },
                        child: Card(
                          color: Colors.green.shade100,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(Icons.work_outline,
                                    size: 40, color: Colors.green),
                                SizedBox(width: 16),
                                Text(
                                  "Jobs Portal",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(8.0),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: [
                    buildGridItem(
                      context,
                      'assets/images/BDS_World_logo.png',
                      'BDS World Groups',
                      BDSWorld(accessToken: accessToken),
                      Color.fromARGB(255, 151, 250, 171),
                    ),
                    buildGridItem(
                      context,
                      'assets/images/ips_logo.png',
                      'Instant Prep Series',
                      IPS(accessToken: accessToken),
                      Color.fromARGB(255, 255, 149, 149),
                    ),
                    buildGridItem(
                      context,
                      'assets/images/career_options.png',
                      'Career Pathways',
                      DentalCareerPathways(accessToken: accessToken),
                      Color.fromARGB(255, 248, 225, 176),
                    ),
                    buildGridItem(
                      context,
                      'assets/images/mock_exams.png',
                      'Licensing Mock Exams',
                      ForeignMockExam(accessToken: accessToken),
                      Color.fromARGB(255, 137, 218, 255),
                    ),
                    buildGridItem(
                      context,
                      'assets/images/UGTests.png',
                      'UG Tests & Exams',
                      ugTestsExams(accessToken: accessToken),
                      Color.fromARGB(255, 253, 187, 248),
                    ),
                    buildGridItem(
                      context,
                      'assets/images/helping_material.png',
                      'UG Material',
                      ugHelpingMaterial(accessToken: accessToken),
                      Color(0xFFFCCC9F),
                    ),
                    buildGridItem(
                      context,
                      'assets/images/free_books.png',
                      'Dental Key Library',
                      Modaldkl(accessToken: accessToken),
                      Color.fromARGB(255, 192, 136, 230),
                    ),
                    buildGridItem(
                      context,
                      'assets/images/multimedia.png',
                      'Video Guidelines',
                      videoguidelines(accessToken: accessToken),
                      Color(0xFFA7FFDD),
                    ),
                    buildGridItem(
                      context,
                      'assets/images/dental_unit.png',
                      'Display Dental Clinic',
                      displayDentalClinic(accessToken: accessToken),
                      Color.fromARGB(255, 203, 160, 160),
                    ),
                    buildGridItem(
                      context,
                      'assets/images/rehanappointment.png',
                      'Make Appointment',
                      appointmentswithdrrehan(accessToken: accessToken),
                      Color.fromARGB(255, 139, 185, 245),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ClinicalCaseDiscussion(accessToken: accessToken),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Column(
                      children: [
                        Image.asset(
                            'assets/images/clinical_case_discussion.png'),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Clinical Case Discussion',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGridItem(BuildContext context, String imagePath, String title,
      Widget destination, Color backgroundColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => destination,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // Added this line
          children: [
            Image.asset(
              imagePath,
              width: 120.0,
              height: 100.0,
            ),
            const SizedBox(height: 10.0),
            Text(
              title,
              textAlign: TextAlign.center, // Added this line
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showLogoutConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Row(
                        children: <Widget>[
                          CircularProgressIndicator(),
                          SizedBox(width: 20),
                          Text("Logging out..."),
                        ],
                      ),
                    );
                  },
                );
                _handleLogout(context);
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('refreshToken');

    if (refreshToken != null) {
      try {
        final response = await http.post(
          Uri.parse(
              'https://dental-key-738b90a4d87a.herokuapp.com/users/logout/'),
          body: json.encode({'refresh_token': refreshToken}),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${prefs.getString('accessToken')}',
          },
        );

        if (response.statusCode == 205) {
          await prefs.remove('accessToken');
          await prefs.remove('refreshToken');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginDental()),
          );
        } else {
          final Map<String, dynamic> responseData = json.decode(response.body);
          String errorMessage =
              responseData['error'] ?? 'Logout failed. Please try again.';
          Navigator.of(context, rootNavigator: true).pop();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Logout Failed'),
              content: Text(errorMessage),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        Navigator.of(context, rootNavigator: true).pop();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred. Please try again later.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginDental()),
      );
    }
  }
}
