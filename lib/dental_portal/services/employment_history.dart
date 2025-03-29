import 'dart:convert';
import 'package:dental_key/dental_portal/services/pending_invitations.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmploymentHistoryScreen extends StatefulWidget {
  final String userEmail;

  const EmploymentHistoryScreen({super.key, required this.userEmail});

  @override
  State<EmploymentHistoryScreen> createState() =>
      _EmploymentHistoryScreenState();
}

class _EmploymentHistoryScreenState extends State<EmploymentHistoryScreen> {
  List history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEmploymentHistory();
  }

  Future<void> fetchEmploymentHistory() async {
    final url = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/employment-history/?email=${widget.userEmail}");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        history = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load employment history")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employment History")),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.mail_outline),
        label: Text("Pending Invites"),
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PendingInvitationsScreen(userEmail: widget.userEmail),
            ),
          );

          if (result == true) {
            fetchEmploymentHistory(); // 👈 Refresh if accepted
          }
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
              ? const Center(child: Text("No employment history found."))
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    final hasEnded = item['ended_on'] != null;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        title: Text(item['practice_name'],
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Role: ${item['role']} (${item['staff_type']})"),
                            Text("Joined: ${item['joined_on'] ?? 'N/A'}"),
                            Text(hasEnded
                                ? "Ended: ${item['ended_on']}"
                                : "Status: Currently Working"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
