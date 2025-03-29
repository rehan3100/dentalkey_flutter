import 'package:flutter/material.dart';
import 'api_service.dart';

class OralExaminationSection extends StatefulWidget {
  final String dependentUuid;

  OralExaminationSection({required this.dependentUuid});

  @override
  _OralExaminationSectionState createState() => _OralExaminationSectionState();
}

class _OralExaminationSectionState extends State<OralExaminationSection> {
  Map<String, dynamic>? oralExaminationData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOralExamination();
  }

  Future<void> _fetchOralExamination() async {
    try {
      final data = await ApiService.fetchDependentDetails(widget.dependentUuid);
      setState(() {
        oralExaminationData = data['oral_examination'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching oral examination data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : oralExaminationData != null
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                        "Extraoral Examination: ${oralExaminationData!['extraoral'] ?? "N/A"}"),
                    Text(
                        "Intraoral Examination: ${oralExaminationData!['intraoral'] ?? "N/A"}"),
                  ],
                ),
              )
            : Center(child: Text("No Oral Examination Data Available"));
  }
}
