import 'package:dental_key/patient_portal/display_nearby_practices.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';

class ProfileSection extends StatefulWidget {
  final String patientId;
  final String dependentUuid;

  ProfileSection({required this.patientId, required this.dependentUuid});

  @override
  _ProfileSectionState createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final data = await ApiService.fetchDependentDetails(widget.dependentUuid);
      setState(() {
        profileData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching profile data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : profileData != null
            ? _buildProfileCard()
            : Center(
                child: Text(
                  "Profile Not Found",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
  }

  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: profileData!['profile_picture'] != null
                        ? Image.network(
                            '${profileData!['profile_picture']}',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.grey.shade400,
                              );
                            },
                          )
                        : Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profileData!['full_name'] ?? "N/A",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "${profileData!['date_of_birth'] ?? 'N/A'} (${_calculateAge(profileData!['date_of_birth'])})",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          profileData!['gender'] ?? "N/A",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          profileData!['next_appointment_date'] != null &&
                                  profileData!['next_appointment_time'] != null
                              ? "${profileData!['next_appointment_date']} at ${profileData!['next_appointment_time']}"
                              : "No Appointment Scheduled",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildFullWidthActionCard(
            icon: Icons.calendar_today,
            title: "Book Appointment",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PracticesPage(
                    patientId: widget.patientId,
                    dependentUuid: widget.dependentUuid,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 10),
          _buildFullWidthActionCard(
            icon: Icons.list_alt,
            title: "View Appointments",
            onTap: () {
              // Navigate to View Appointments page
            },
          ),
          SizedBox(height: 10),
          _buildFullWidthActionCard(
            icon: Icons.lightbulb_outline,
            title: "Personalized Advice",
            onTap: () {
              // Navigate to Personalized Advice page
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFullWidthActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: Colors.blueAccent,
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _calculateAge(String? dob) {
    if (dob == null || dob.isEmpty) return "Unknown";
    try {
      final birthDate = DateTime.parse(dob);
      final today = DateTime.now();
      int years = today.year - birthDate.year;
      int months = today.month - birthDate.month;
      if (months < 0) {
        years--;
        months += 12;
      }
      return "$years years ${months > 0 ? "$months months" : ""}";
    } catch (e) {
      return "Invalid DOB";
    }
  }
}
