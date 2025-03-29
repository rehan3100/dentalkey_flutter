import 'package:flutter/material.dart';
import 'profile_section.dart';
import 'medical_history_section.dart';
import 'oral_examination_section.dart';
import 'radiographs_section.dart';
import 'referrals_section.dart';
import 'prescriptions_section.dart';
import 'package:dental_key/patient_portal/profile_options/edit_profile.dart';

class DependentProfilePage2 extends StatefulWidget {
  final String patientId;
  final String dependentUuid;

  DependentProfilePage2({required this.patientId, required this.dependentUuid});

  @override
  _DependentProfilePageState createState() => _DependentProfilePageState();
}

class _DependentProfilePageState extends State<DependentProfilePage2> {
  int _currentIndex = 0;

  final List<String> _sections = [
    "Profile",
    "Medical History",
    "Oral Examination",
    "Radiographs",
    "Referrals",
    "Prescriptions"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_sections[_currentIndex]),
        backgroundColor: Colors.blueAccent,
        actions: _currentIndex == 0
            ? [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditDependentPage(
                          patientId: widget.patientId,
                          dependentUuid: widget.dependentUuid,
                        ),
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: _buildContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _sections
            .map((section) => BottomNavigationBarItem(
                  icon: Icon(Icons.circle),
                  label: section,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentIndex) {
      case 0:
        return ProfileSection(
          patientId: widget.patientId,
          dependentUuid: widget.dependentUuid,
        );
      case 1:
        return MedicalHistorySection(dependentUuid: widget.dependentUuid);
      case 2:
        return OralExaminationSection(dependentUuid: widget.dependentUuid);
      case 3:
        return RadiographsSection(dependentUuid: widget.dependentUuid);
      case 4:
        return ReferralsSection(dependentUuid: widget.dependentUuid);
      case 5:
        return PrescriptionsSection(dependentUuid: widget.dependentUuid);
      default:
        return Center(child: Text("Invalid Section"));
    }
  }
}
