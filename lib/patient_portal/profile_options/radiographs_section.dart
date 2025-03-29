import 'package:flutter/material.dart';
import 'api_service.dart';

class RadiographsSection extends StatefulWidget {
  final String dependentUuid;

  RadiographsSection({required this.dependentUuid});

  @override
  _RadiographsSectionState createState() => _RadiographsSectionState();
}

class _RadiographsSectionState extends State<RadiographsSection> {
  List<dynamic>? radiographsData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRadiographs();
  }

  Future<void> _fetchRadiographs() async {
    try {
      final data = await ApiService.fetchDependentDetails(widget.dependentUuid);
      setState(() {
        radiographsData = data['radiographs'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching radiographs data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : radiographsData != null && radiographsData!.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: radiographsData!.map((radiograph) {
                    return ListTile(
                      leading: Icon(Icons.medical_services,
                          color: Colors.blueAccent),
                      title: Text(radiograph['type'] ?? "Unknown"),
                      subtitle:
                          Text("Taken on: ${radiograph['date'] ?? "N/A"}"),
                    );
                  }).toList(),
                ),
              )
            : Center(child: Text("No Radiographs Available"));
  }
}
