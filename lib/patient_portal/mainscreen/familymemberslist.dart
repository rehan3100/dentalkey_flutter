import 'package:dental_key/patient_portal/mainscreen/upgrademembership.dart';
import 'package:dental_key/patient_portal/profile_options/create_dependent.dart';
import 'package:dental_key/patient_portal/profile_options/dependent_profile_page.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dental_key/patient_portal/mainscreen/selectedmember.dart';
import 'package:dental_key/patient_portal/profile_options/update_main_patient_id.dart';

class DependentsListPage extends StatefulWidget {
  final String patientId;
  DependentsListPage({required this.patientId});

  @override
  _DependentsListPageState createState() => _DependentsListPageState();
}

class _DependentsListPageState extends State<DependentsListPage> {
  bool _isLoading = true;
  List<dynamic> allDependents = [];
  String membershipType = '';
  String patientName = ''; // Store patient's name
  String greetingMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDependentsData();
    _setGreetingMessage(); // Set greeting based on time
  }

  // Fetch dependents data and membership types in one API call
  Future<void> _fetchDependentsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getString('patientId');
      if (patientId == null) {
        throw Exception("Patient ID not found in SharedPreferences");
      }

      final response = await http.get(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/patients_dental/patient-details/$patientId/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Fetch the patient details
        final patient = data['patient'];
        final selfDependent =
            data['self_dependent']; // Fetch the self-dependent
        final dependents =
            data['other_dependents'] ?? []; // Fetch other dependents

        // Get the patient name, membership type, and available membership types
        patientName = patient['full_name'] ?? 'Patient'; // Store patient's name
        membershipType = patient['membership_type'] ?? '';

        setState(() {
          // Add self-dependent as the first item in the list
          allDependents = [selfDependent, ...dependents];
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch dependents data");
      }
    } catch (e) {
      _showErrorDialog("Failed to load data. Please try again.");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Set greeting message based on the time of the day
  void _setGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greetingMessage = 'Good Morning';
    } else if (hour < 17) {
      greetingMessage = 'Good Afternoon';
    } else {
      greetingMessage = 'Good Evening';
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
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

  // Navigate to PatientMainPortalPage with the selected dependent's data
  void _navigateToPatientMainPortalPage(String dependentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientMainPortalPage(
          patientId: widget.patientId,
          dependentId: dependentId, // Pass dependent UUID
        ),
      ),
    );
  }

  // Navigate to Update Profile Page
  void _navigateToUpdateProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateProfilePage(patientId: widget.patientId),
      ),
    );
  }

  void _createDependent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateDependentPage(patientId: widget.patientId),
      ),
    );
  }

  // Pull-to-refresh function
  Future<void> _onRefresh() async {
    await _fetchDependentsData(); // Refresh the data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disable back swipe
        title: Text("$greetingMessage, $patientName!"), // Greeting message
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _onRefresh, // Trigger refresh when button is pressed
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh, // Trigger on pull-to-refresh
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Determine the card size dynamically based on the available width
                          double cardSize = (constraints.maxWidth - 16) /
                              2; // Half the width minus spacing

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Left Card with Profile Picture
                              Container(
                                width: cardSize,
                                height: cardSize, // Ensure square aspect ratio
                                child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      image: allDependents.isNotEmpty &&
                                              allDependents[0]
                                                      ['relationship'] ==
                                                  "Self" &&
                                              allDependents[0]
                                                      ['profile_picture'] !=
                                                  null
                                          ? DecorationImage(
                                              // Append a timestamp to the image URL to avoid caching
                                              image: NetworkImage(
                                                '${allDependents[0]['profile_picture']}?timestamp=${DateTime.now().millisecondsSinceEpoch}',
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                      color: allDependents.isNotEmpty &&
                                              allDependents[0]
                                                      ['relationship'] ==
                                                  "Self"
                                          ? Colors.grey.shade300
                                          : Colors.grey.shade400,
                                    ),
                                    child: allDependents.isNotEmpty &&
                                            allDependents[0]['relationship'] ==
                                                "Self" &&
                                            allDependents[0]
                                                    ['profile_picture'] ==
                                                null
                                        ? Center(
                                            child: Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.grey.shade600,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),

                              // Right Card
                              Container(
                                width: cardSize,
                                height: cardSize, // Ensure square aspect ratio
                                child: GestureDetector(
                                  onTap:
                                      _showFamilyMembersDialog, // Trigger popup dialog
                                  child: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.groups,
                                              size: 50,
                                              color: Colors
                                                  .blueAccent), // Family team logo
                                          SizedBox(height: 10),
                                          Text(
                                            "View Family Members",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueAccent,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Determine the card size dynamically based on the available width
                          double cardSize = (constraints.maxWidth - 16) /
                              2; // Half the width minus spacing

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Left Card: Edit Profile
                              Container(
                                width: cardSize,
                                height: cardSize, // Ensure square aspect ratio
                                child: GestureDetector(
                                  onTap:
                                      _navigateToUpdateProfile, // Navigate to Edit Profile
                                  child: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.edit, // Edit Profile icon
                                            size: 60,
                                            color: Colors.blueAccent,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "Edit Profile",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Right Card: Logo
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UpgradeMembershipPage(
                                              patientId: widget.patientId),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: cardSize,
                                  height:
                                      cardSize, // Ensure square aspect ratio
                                  child: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Membership Image
                                        Container(
                                          width: cardSize *
                                              0.6, // Decrease the size of the image
                                          height: cardSize * 0.6,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                15), // Match the card's border radius
                                            image: DecorationImage(
                                              image: AssetImage(
                                                _getMembershipImage(), // Get the image based on membership type
                                              ),
                                              fit: BoxFit
                                                  .cover, // Ensures the image fits within the container
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            height:
                                                10), // Spacing between image and text

                                        // Upgrade / Downgrade Text
                                        Text(
                                          "Upgrade / Downgrade Membership",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity, // Full-width button
                        child: ElevatedButton(
                          onPressed:
                              _showDependentsList, // Show dependents list
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Let's Go..",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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

  // Calculate age from the date of birth
  int _calculateAge(DateTime dateOfBirth) {
    final today = DateTime.now();
    final age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      return age - 1;
    }
    return age;
  }

  void _showDependentsList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(15), // Rounded corners for aesthetics
        ),
        title: Center(
          child: Text(
            "Which Profile Will You Choose Today?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        ),
        content: SizedBox(
          height: 200, // Set fixed height for the list
          child: allDependents.isNotEmpty
              ? ListView.separated(
                  itemCount: allDependents.length,
                  itemBuilder: (context, index) {
                    var dependent = allDependents[index];

                    // Print full dependent details for debugging
                    print("Dependent Details: ${json.encode(dependent)}");

                    return GestureDetector(
                      onTap: () {
                        // Extract and validate ID
                        String dependentUuid = dependent['id'] ?? "No UUID";
                        print("Selected Dependent UUID: $dependentUuid");

                        // Navigate to DependentProfilePage
                        Navigator.of(context).pop(); // Close the dialog first
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DependentProfilePage2(
                              patientId: widget.patientId, // Pass patientId
                              dependentUuid:
                                  dependentUuid, // Pass dependentUuid
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                dependent['profile_picture'] != null
                                    ? NetworkImage(
                                        '${dependent['profile_picture']}?timestamp=${DateTime.now().millisecondsSinceEpoch}',
                                      )
                                    : null,
                            backgroundColor: Colors.grey.shade300,
                            child: dependent['profile_picture'] == null
                                ? Icon(Icons.person, color: Colors.grey)
                                : null,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              dependent['full_name'] ?? "Unknown",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                    thickness: 0.5,
                    color: Colors.grey.shade400,
                  ),
                )
              : Center(
                  child: Text(
                    "No Dependents Found",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "Close",
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  // Show success dialog after updating membership type
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text('Membership type updated successfully!'),
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

  void _showFamilyMembersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Family Members"),
            IconButton(
              icon: Icon(Icons.add, color: Colors.blueAccent), // Plus button
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _createDependent(); // Navigate to CreateDependentPage
              },
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: allDependents.length,
            itemBuilder: (context, index) {
              var dependent = allDependents[index];
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: dependent['profile_picture'] != null
                        ? Image.network(
                            '${dependent['profile_picture']}?timestamp=${DateTime.now().millisecondsSinceEpoch}', // Add a timestamp to bypass cache
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey.shade400,
                          ),
                  ),
                  title: Text(
                    dependent['full_name'] ?? "Unknown",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Relationship: ${dependent['relationship']}\nAge: ${_calculateAgeWithDOB(DateTime.parse(dependent['date_of_birth']))}",
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  String _calculateAgeWithDOB(DateTime dateOfBirth) {
    final today = DateTime.now();
    int years = today.year - dateOfBirth.year;
    int months = today.month - dateOfBirth.month;

    // Adjust years and months if the birthday hasn't occurred yet this year
    if (months < 0) {
      years -= 1;
      months += 12;
    }

    return "$years Years, $months Months (DOB: ${dateOfBirth.toLocal().toString().split(' ')[0]})";
  }

  String _getMembershipImage() {
    switch (membershipType.toLowerCase()) {
      case 'diamond':
        return 'assets/images/diamond.jpg';
      case 'gold':
        return 'assets/images/gold.jpg';
      case 'silver':
        return 'assets/images/silver.jpg';
      default:
        return 'assets/logo.png'; // Default image if membership type is not recognized
    }
  }

  void _navigateToUpgradeMembership() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            UpgradeMembershipPage(patientId: widget.patientId),
      ),
    );
  }
}
