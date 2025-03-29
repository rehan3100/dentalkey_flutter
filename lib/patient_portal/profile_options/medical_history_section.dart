import 'package:flutter/material.dart';
import 'api_service.dart';

class MedicalHistorySection extends StatefulWidget {
  final String dependentUuid;

  MedicalHistorySection({required this.dependentUuid});

  @override
  _MedicalHistorySectionState createState() => _MedicalHistorySectionState();
}

class _MedicalHistorySectionState extends State<MedicalHistorySection> {
  Map<String, dynamic>? medicalHistoryData;
  bool isLoading = true;
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchMedicalHistory();
  }

  Future<void> _fetchMedicalHistory() async {
    try {
      final data = await ApiService.fetchMedicalHistory(widget.dependentUuid);
      print('Received medical history data: $data'); // Debugging line
      setState(() {
        medicalHistoryData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching medical history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : medicalHistoryData != null
            ? _buildMedicalHistoryContent()
            : Center(
                child: Text(
                  "No medical history available.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
  }

  Widget _buildMedicalHistoryContent() {
    final rawMedicalProblems = medicalHistoryData!['medical_problems'] ?? {};
    final medications = medicalHistoryData!['medications'] ?? [];
    final allergies = medicalHistoryData!['allergies'] ?? {};
    final lifestyleHabits = (medicalHistoryData!['lifestyle_habits'] ?? {})
        .map<String, dynamic>((key, value) => MapEntry(key.toString(), value));

    final bodyMetrics = (medicalHistoryData!['body_metrics'] ?? {})
        .map<String, dynamic>((key, value) => MapEntry(key.toString(), value));

    Map<String, dynamic> medicalProblems = {};
    if (rawMedicalProblems is Map<String, dynamic>) {
      medicalProblems = rawMedicalProblems;
    }

    return Column(
      children: [
        // Page Indicators
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => _buildPageIndicator(index)),
          ),
        ),

        // PageView for Swiping
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              // Diseases Page
              _buildMedicalSectionCard(
                title: "Diseases",
                icon: Icons.healing,
                content: _buildDiseasesContent(medicalProblems),
              ),

              // Medications Page
              _buildMedicalSectionCard(
                title: "Medications",
                icon: Icons.local_pharmacy,
                content: medications.isEmpty
                    ? [_buildEmptyMessage("Not taking any medications.")]
                    : medications.map<Widget>((med) {
                        return ListTile(
                          leading:
                              Icon(Icons.medication, color: Colors.blueAccent),
                          title: Text(med['medicine_name'] ?? 'N/A'),
                          subtitle: Text(
                            "Dosage: ${med['dosage'] ?? 'N/A'}\nPrescribed for: ${med['prescribed_for'] ?? 'N/A'}",
                          ),
                        );
                      }).toList(),
              ),

              // Allergies Page
              _buildMedicalSectionCard(
                title: "Allergies",
                icon: Icons.bug_report,
                content: allergies.entries.where((e) => e.value == true).isEmpty
                    ? [_buildEmptyMessage("No allergies recorded.")]
                    : allergies.entries
                        .where((e) => e.value == true)
                        .map<Widget>((allergy) {
                        return ListTile(
                          leading: Icon(Icons.warning, color: Colors.redAccent),
                          title: Text(_formatDiseaseName(allergy.key)),
                        );
                      }).toList(),
              ),

              // Lifestyle Habits Page
              _buildMedicalSectionCard(
                title: "Lifestyle Habits",
                icon: Icons.directions_run,
                content: _buildLifestyleHabitsContent(lifestyleHabits),
              ),

              // Body Metrics Page
              _buildMedicalSectionCard(
                title: "Body Metrics",
                icon: Icons.monitor_weight,
                content: _buildBodyMetricsContent(bodyMetrics),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ Build Lifestyle Habits Content
  List<Widget> _buildLifestyleHabitsContent(
      Map<String, dynamic> lifestyleHabits) {
    if (lifestyleHabits.isEmpty) {
      return [_buildEmptyMessage("No lifestyle habits recorded.")];
    }

    return lifestyleHabits.entries
        .where((e) => e.value is bool || e.value is String || e.value is num)
        .map((entry) => ListTile(
              leading: Icon(Icons.fitness_center, color: Colors.green),
              title: Text(_formatCategoryName(entry.key)),
              subtitle: (entry.value is bool)
                  ? (entry.value ? Text("Yes") : Text("No"))
                  : Text(entry.value.toString()),
            ))
        .toList();
  }

  // ✅ Build Body Metrics Content
  List<Widget> _buildBodyMetricsContent(Map<String, dynamic> bodyMetrics) {
    if (bodyMetrics.isEmpty) {
      return [_buildEmptyMessage("No body metrics recorded.")];
    }

    return [
      _buildMetricTile(
          "Height",
          bodyMetrics['height_cm'] != null
              ? "${bodyMetrics['height_cm']} cm"
              : "N/A"),
      _buildMetricTile(
          "Weight",
          bodyMetrics['weight_kg'] != null
              ? "${bodyMetrics['weight_kg']} kg"
              : "N/A"),
      _buildMetricTile("BMI",
          bodyMetrics['bmi'] != null ? bodyMetrics['bmi'].toString() : "N/A"),
      _buildMetricTile(
          "Obesity", bodyMetrics['obesity'] == true ? "Yes" : "No"),
      _buildMetricTile(
          "Underweight", bodyMetrics['underweight'] == true ? "Yes" : "No"),
      _buildMetricTile(
          "Overweight", bodyMetrics['overweight'] == true ? "Yes" : "No"),
    ];
  }

  // Helper Widget for Body Metrics
  Widget _buildMetricTile(String label, String value) {
    return ListTile(
      leading: Icon(Icons.info_outline, color: Colors.blueAccent),
      title: Text(label),
      subtitle: Text(value),
    );
  }

  List<Widget> _buildDiseasesContent(Map<String, dynamic> medicalProblems) {
    if (medicalProblems.entries.isEmpty) {
      return [_buildEmptyMessage("Not suffering from any disease.")];
    }

    List<Widget> widgets = [];
    for (var entry in medicalProblems.entries) {
      final categoryName = _formatCategoryName(entry.key);
      final diseases = (entry.value as Map<String, dynamic>)
          .entries
          .where((e) => e.value == true)
          .toList();

      if (diseases.isNotEmpty) {
        widgets.add(_buildCategoryTitle(categoryName));
        widgets
            .addAll(diseases.map((disease) => _buildDiseaseItem(disease.key)));
      } else {
        widgets
            .add(_buildEmptyMessage("No diseases recorded in $categoryName."));
      }
    }
    return widgets;
  }

  Widget _buildPageIndicator(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      width: _currentPage == index ? 12.0 : 8.0,
      height: _currentPage == index ? 12.0 : 8.0,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blueAccent : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildMedicalSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> content,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.blueAccent, size: 28),
                  SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Divider(color: Colors.grey.shade400),
              SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: content,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyMessage(String message) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        message,
        style: TextStyle(fontSize: 16, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCategoryTitle(String categoryName) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: Text(
        categoryName,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDiseaseItem(String diseaseName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 18),
          SizedBox(width: 8),
          Text(
            _formatDiseaseName(diseaseName),
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  String _formatCategoryName(String category) {
    return category.replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _formatDiseaseName(String disease) {
    return disease.replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

// ✅ Function to display an empty message
Widget _buildEmptyMessage(String message) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Text(
      message,
      style: TextStyle(fontSize: 16, color: Colors.grey),
      textAlign: TextAlign.center,
    ),
  );
}

// ✅ Function to format disease names (replace underscores with spaces and capitalize)
String _formatDiseaseName(String disease) {
  return disease.replaceAll('_', ' ').split(' ').map((word) {
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

// ✅ Function to format category names (for different sections)
String _formatCategoryName(String category) {
  return category.replaceAll('_', ' ').split(' ').map((word) {
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

// ✅ Function to build category title (section headers)
Widget _buildCategoryTitle(String categoryName) {
  return Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 5),
    child: Text(
      categoryName,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),
  );
}

// ✅ Function to build disease items (with green checkmark)
Widget _buildDiseaseItem(String diseaseName) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 18),
        SizedBox(width: 8),
        Text(
          _formatDiseaseName(diseaseName),
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    ),
  );
}
