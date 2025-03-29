import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ServicesTab extends StatefulWidget {
  final String practiceId;

  ServicesTab({required this.practiceId});

  @override
  _ServicesTabState createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> {
  List<dynamic> availableServices = [];
  List<String> selectedServiceIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchServicesData();
  }

  Future<void> fetchServicesData() async {
    setState(() => isLoading = true);

    final allServicesUrl = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/all-services/");
    final selectedServicesUrl = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/practice-services/${widget.practiceId}/");

    try {
      final allResponse = await http.get(allServicesUrl);
      final selectedResponse = await http.get(selectedServicesUrl);

      if (allResponse.statusCode == 200 && selectedResponse.statusCode == 200) {
        final all = jsonDecode(allResponse.body);
        final selected = jsonDecode(selectedResponse.body);
        setState(() {
          availableServices = all;
          selectedServiceIds =
              List<String>.from(selected.map((s) => s['id'].toString()));
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch services");
      }
    } catch (e) {
      print("❌ Error fetching services: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load services")),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> updateServices() async {
    final url = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/practice-services/${widget.practiceId}/");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"service_ids": selectedServiceIds}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Services updated successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to update services")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: availableServices.map((service) {
                      final id = service['id'].toString();
                      final name = service['name'];
                      return CheckboxListTile(
                        title: Text(name),
                        value: selectedServiceIds.contains(id),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedServiceIds.add(id);
                            } else {
                              selectedServiceIds.remove(id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: updateServices,
                  icon: Icon(Icons.save),
                  label: Text("Save Services"),
                ),
              ],
            ),
          );
  }
}
