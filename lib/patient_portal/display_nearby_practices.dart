import 'dart:convert';
import 'package:dental_key/patient_portal/practice_profile_for_patients.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class PracticesPage extends StatefulWidget {
  final String patientId;
  final String dependentUuid;

  PracticesPage({required this.patientId, required this.dependentUuid});

  @override
  _PracticesPageState createState() => _PracticesPageState();
}

class _PracticesPageState extends State<PracticesPage> {
  List<Map<String, dynamic>> practices = [];
  bool isLoading = true;

  String searchQuery = '';
  String selectedFilter = 'Mixed (Both)';
  String selectedSort = 'Distance';

  final List<String> filterOptions = ['NHS', 'Private', 'Mixed (Both)'];
  final List<String> sortOptions = ['Distance', 'Rating'];

  Future<void> fetchPractices() async {
    final uri = Uri.parse(
      'https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/approved-practices/?patient_id=${widget.patientId}&dependent_uuid=${widget.dependentUuid}',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        practices = List<Map<String, dynamic>>.from(data['practices']);
        isLoading = false;
      });
    } else {
      print('Failed to load practices');
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPractices();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtered = practices.where((p) {
      final name = p['name']?.toString().toLowerCase() ?? '';
      final type = p['type']?.toString().toLowerCase() ?? '';
      return (selectedFilter == 'Mixed (Both)' ||
              p['type'] == selectedFilter) &&
          (name.contains(searchQuery.toLowerCase()) ||
              type.contains(searchQuery.toLowerCase()));
    }).toList();

    if (selectedSort == 'Distance') {
      filtered.sort((a, b) => a['distance'].compareTo(b['distance']));
    } else {
      filtered.sort((a, b) => b['rating'].compareTo(a['rating']));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2196F3),
        title: Text('Nearby Practices'),
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    // 🔍 Search Bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Search by name or area...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) => setState(() => searchQuery = value),
                    ),
                    SizedBox(height: 10),

                    // 🔽 Filter & Sort
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedFilter,
                            decoration: InputDecoration(
                              labelText: 'Filter by Type',
                              border: OutlineInputBorder(),
                            ),
                            items: filterOptions
                                .map((f) => DropdownMenuItem(
                                      value: f,
                                      child: Text(f),
                                    ))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => selectedFilter = val!),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedSort,
                            decoration: InputDecoration(
                              labelText: 'Sort by',
                              border: OutlineInputBorder(),
                            ),
                            items: sortOptions
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => selectedSort = val!),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    // 📋 Practice List
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(child: Text("No practices found."))
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (_, index) => PracticeCard(
                                    practice: filtered[index],
                                    patientId: widget.patientId,
                                    dependentUuid: widget.dependentUuid,
                                  )),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class PracticeCard extends StatefulWidget {
  final Map<String, dynamic> practice;
  final String patientId;
  final String dependentUuid;

  PracticeCard({
    required this.practice,
    required this.patientId,
    required this.dependentUuid,
  });

  @override
  _PracticeCardState createState() => _PracticeCardState();
}

class _PracticeCardState extends State<PracticeCard> {
  @override
  Widget build(BuildContext context) {
    final practice = widget.practice;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PracticeProfileScreen(
                    practiceId: practice['id'],
                    patientId: widget.patientId,
                    dependentUuid: widget.dependentUuid,
                  )),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            practice['image'] != null && practice['image'].toString().isNotEmpty
                ? Image.network(
                    practice['image'],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/default_practice.jpg',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    'assets/images/default_practice.jpg',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(practice['name'],
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("${practice['type']} Practice"),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(
                          "${practice['rating']} (${practice['reviews']} reviews)"),
                      Spacer(),
                      Text("${practice['distance']} km"),
                    ],
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    child: Text("Book Appointment"),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => AppointmentRequestDialog(
                        practiceName: practice['name'],
                        patientId: widget.patientId,
                        dependentUuid: widget.dependentUuid,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppointmentRequestDialog extends StatefulWidget {
  final String practiceName;
  final String patientId;
  final String dependentUuid;

  AppointmentRequestDialog({
    required this.practiceName,
    required this.patientId,
    required this.dependentUuid,
  });

  @override
  _AppointmentRequestDialogState createState() =>
      _AppointmentRequestDialogState();
}

class _AppointmentRequestDialogState extends State<AppointmentRequestDialog> {
  String selectedFor = 'Self';
  TextEditingController reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Request Appointment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedFor,
            items: ['Self', 'John (Son)', 'Fatima (Spouse)']
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (val) => setState(() => selectedFor = val!),
            decoration: InputDecoration(labelText: 'Booking for'),
          ),
          TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: InputDecoration(labelText: 'Describe issue or reason'),
          ),
        ],
      ),
      actions: [
        TextButton(
            child: Text('Cancel'), onPressed: () => Navigator.pop(context)),
        ElevatedButton(
          child: Text('Submit'),
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Request sent to ${widget.practiceName}")),
            );
            // TODO: Call API
          },
        ),
      ],
    );
  }
}
