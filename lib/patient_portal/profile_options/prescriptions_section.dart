import 'package:flutter/material.dart';
import 'api_service.dart';

class PrescriptionsSection extends StatefulWidget {
  final String dependentUuid;

  PrescriptionsSection({required this.dependentUuid});

  @override
  _PrescriptionsSectionState createState() => _PrescriptionsSectionState();
}

class _PrescriptionsSectionState extends State<PrescriptionsSection> {
  List<dynamic>? prescriptionsData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPrescriptions();
  }

  Future<void> _fetchPrescriptions() async {
    try {
      final data = await ApiService.fetchDependentDetails(widget.dependentUuid);
      setState(() {
        prescriptionsData = data['prescriptions'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching prescriptions data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : prescriptionsData != null && prescriptionsData!.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: prescriptionsData!.map((prescription) {
                    return ListTile(
                      leading: Icon(Icons.medical_services,
                          color: Colors.blueAccent),
                      title: Text(
                          prescription['medicine_name'] ?? "Unknown Medicine"),
                      subtitle:
                          Text("Dosage: ${prescription['dosage'] ?? "N/A"}"),
                    );
                  }).toList(),
                ),
              )
            : Center(child: Text("No Prescriptions Available"));
  }
}
