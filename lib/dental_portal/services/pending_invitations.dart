import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PendingInvitationsScreen extends StatefulWidget {
  final String userEmail;

  const PendingInvitationsScreen({super.key, required this.userEmail});

  @override
  State<PendingInvitationsScreen> createState() =>
      _PendingInvitationsScreenState();
}

class _PendingInvitationsScreenState extends State<PendingInvitationsScreen> {
  List invitations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInvitations();
  }

  Future<void> fetchInvitations() async {
    final url = Uri.parse(
      "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/pending-invitations/?email=${widget.userEmail}",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        invitations = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch invitations")),
      );
    }
  }

  Future<void> respondToInvitation(String invitationId, String action) async {
    final url = Uri.parse(
      "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/respond-invitation/",
    );

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "invitation_id": invitationId,
        "action": action,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Invitation ${action == 'accept' ? 'accepted' : 'declined'}")),
      );

      // If accepted, go back and trigger refresh
      if (action == 'accept' && context.mounted) {
        Navigator.pop(context, true); // 👈 Pass true to refresh
      } else {
        fetchInvitations(); // Refresh if declined
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Action failed. Please try again.")),
      );
    }
  }

  Widget buildInfo(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text("$label: $value"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pending Invitations")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : invitations.isEmpty
              ? const Center(child: Text("No pending invitations"))
              : ListView.builder(
                  itemCount: invitations.length,
                  itemBuilder: (context, index) {
                    final invite = invitations[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(invite['practice_name'],
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            buildInfo("Role", invite['role']),
                            buildInfo("Type", invite['staff_type']),
                            buildInfo("Invited By",
                                "${invite['invited_by']['name']} (${invite['invited_by']['email']})"),
                            buildInfo("Invitation Date",
                                invite['invited_on']?.split("T")[0]),
                            buildInfo(
                                "Job Starting Date", invite['date_joining']),
                            buildInfo("Job Ending Date", invite['date_ending']),
                            buildInfo(
                                "Notice Period",
                                invite['notice_period_weeks'] != null
                                    ? "${invite['notice_period_weeks']} weeks"
                                    : null),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () => respondToInvitation(
                                      invite['id'], "accept"),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                  child: const Text("Accept"),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () => respondToInvitation(
                                      invite['id'], "decline"),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  child: const Text("Decline"),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
