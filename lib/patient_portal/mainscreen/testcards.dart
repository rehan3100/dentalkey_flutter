import 'package:dental_key/patient_portal/profile_options/edit_profile.dart';
import 'package:dental_key/patient_portal/profile_options/patientprofile.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Testcards extends StatefulWidget {
  final String patientId;

  Testcards({required this.patientId});

  @override
  _TestcardsState createState() => _TestcardsState();
}

class _TestcardsState extends State<Testcards> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  // Patient and dependent details
  String? name;
  String? relationship;
  int? age;
  String? nextCheckupDate;
  String? profilePicture;
  String? nextAppointmentTime;
  Map<String, dynamic>? selfFamilyMember;
  List<dynamic> allDependents = [];

  String?
      selectedDependent; // Local variable to store the UUID of the selected dependent

  // Handle bottom navigation selection
  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

  // Fetch patient and dependents data
  Future<void> _fetchPatientData() async {
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

        // Fetch patient and dependents data
        final patient = data['patient'];
        final selfDependent = data['self_dependent'];
        final dependents = data['other_dependents'] ?? [];

        // Set initial data
        setState(() {
          name = patient['full_name'];
          selfFamilyMember = selfDependent;
          allDependents = [selfDependent, ...dependents];

          // Initialize Profile Card with "Self" details
          relationship = selfDependent['relationship'];
          profilePicture = selfDependent['profile_picture'];
          nextCheckupDate =
              selfDependent['next_appointment_date'] ?? 'No checkup scheduled';
          nextAppointmentTime =
              selfDependent['next_appointment_time'] ?? 'No time scheduled';
          age = _calculateAge(DateTime.parse(selfDependent['date_of_birth']));

          _isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch patient data");
      }
    } catch (e) {
      _showErrorDialog("Failed to load data. Please try again.");
      setState(() {
        _isLoading = false;
      });
      print("Error: $e");
    }
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

  // Change profile dialog
  void _showChangeProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select a Dependent"),
          content: Container(
            width: double.maxFinite,
            height: 200,
            child: ListView.builder(
              itemCount: allDependents.length,
              itemBuilder: (context, index) {
                var dependent = allDependents[index];
                return ListTile(
                  title: Text(
                      "${dependent['full_name']} (${dependent['relationship']})"),
                  onTap: () {
                    setState(() {
                      // Store the UUID of the selected dependent
                      selectedDependent = dependent['uuid'];
                    });
                    Navigator.pop(context);
                    _navigateToEditProfile(); // Navigate to edit profile page
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Navigate to the Edit Dependent Profile screen
  void _navigateToEditProfile() {
    if (selectedDependent != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditDependentProfilePage(
            dependentId: selectedDependent!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          _isLoading ? "Loading..." : "Welcome, $name!",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPatientData,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileSection(),
                    _buildOralCavityChart(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Explore More",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent),
                          ),
                          SizedBox(height: 10),
                          _buildExploreSection(),
                          SizedBox(height: 20),
                          _buildSearchBar(),
                          SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              print("Navigating to Teledental Professionals");
                            },
                            icon: Icon(Icons.video_call),
                            label: Text("TeleDental Professionals"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined), label: "Appointments"),
          BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined), label: "Records"),
          BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined), label: "Explore"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Profile"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  // Profile Section Widget
  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: () {
          _showProfileOptionsDialog();
        },
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: profilePicture != null
                    ? NetworkImage(profilePicture!) // Load image from network
                    : AssetImage('assets/placeholder.png')
                        as ImageProvider, // Fallback image
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${selfFamilyMember?['full_name'] ?? "Dependent Name"} ($relationship)",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Age: $age",
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Next Check-Up: $nextCheckupDate",
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Appointment Time: $nextAppointmentTime",
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Oral Cavity Chart Widget
  Widget _buildOralCavityChart() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Key Parts of Oral Cavity",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCavityPart("Tongue"),
                _buildCavityPart("Palate"),
                _buildCavityPart("Gums"),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCavityPart("Teeth"),
                _buildCavityPart("Soft Tissue"),
                _buildCavityPart("Uvula"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Cavity Part Widget
  Widget _buildCavityPart(String part) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(part),
            content: Text("Details about $part."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Close"),
              ),
            ],
          ),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blueAccent.shade100,
            child: Icon(Icons.medical_services, color: Colors.white),
          ),
          SizedBox(height: 5),
          Text(
            part,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Explore Section Widget
  Widget _buildExploreSection() {
    return Container(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildTipCard(
              title: "Best Practices for Brushing",
              imageUrl: "https://via.placeholder.com/150"),
          _buildTipCard(
              title: "Foods to Avoid",
              imageUrl: "https://via.placeholder.com/150"),
        ],
      ),
    );
  }

  // Tip Card Widget
  Widget _buildTipCard({required String title, required String imageUrl}) {
    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 4,
        child: Column(
          children: [
            Image.network(
              imageUrl,
              height: 80,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Search Bar Widget
  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        labelText: "Search Nearby Practices",
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onSubmitted: (query) {
        print("Search submitted: $query");
        // Handle search
      },
    );
  }

  void _showProfileOptionsDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: Colors.blue),
              title: Text("Edit My Profile"),
            ),
            ListTile(
              leading: Icon(Icons.group_add, color: Colors.green),
              title: Text("Add Family Members"),
              onTap: () {
                print("Add Family Members selected");
                Navigator.pop(context); // Close the bottom sheet
              },
            ),
            ListTile(
              leading: Icon(Icons.lock, color: Colors.orange),
              title: Text("Change Profile"),
              onTap: () {
                print("Change Profile selected");
                Navigator.pop(context); // Close the bottom sheet
                _showChangeProfileDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.lock, color: Colors.orange),
              title: Text("Change Password"),
              onTap: () {
                print("Change Password selected");
                Navigator.pop(context); // Close the bottom sheet
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Logout"),
              onTap: () {
                print("Logout selected");
                Navigator.pop(context); // Close the bottom sheet
              },
            ),
          ],
        );
      },
    );
  }
}
