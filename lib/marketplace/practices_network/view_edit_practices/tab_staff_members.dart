import 'dart:convert';
import 'package:dental_key/marketplace/practices_network/view_edit_practices/add_staff_members.dart';
import 'package:dental_key/marketplace/practices_network/view_edit_practices/view_edit_practices.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StaffListScreen extends StatefulWidget {
  final String practiceId;
  final String ownerEmail;

  const StaffListScreen({
    super.key,
    required this.practiceId,
    required this.ownerEmail,
  });

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  List staffList = [];
  bool isLoading = true;

  int allowedStaffCount = 0;
  bool showUpgradeBanner = true;

  @override
  void initState() {
    super.initState();
    fetchAllowedStaff();
    fetchStaffMembers();
  }

  Future<void> fetchAllowedStaff() async {
    final url = Uri.parse(
      "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/packages/${widget.practiceId}/",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        allowedStaffCount = data['max_staff'] ?? 0;
      });
    } else {
      print("⚠️ Failed to fetch allowed staff from package");
    }
  }

  Future<void> fetchStaffMembers() async {
    setState(() => isLoading = true);

    final url = Uri.parse(
      "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/staff-list/${widget.practiceId}/",
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-User-Email': widget.ownerEmail,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        staffList = data;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch staff members")),
      );
    }
  }

  Future<void> _navigateToInviteScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InviteStaffScreen(
          practiceId: widget.practiceId,
          ownerEmail: widget.ownerEmail,
        ),
      ),
    );

    if (result == true) {
      fetchStaffMembers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (staffList.length >= allowedStaffCount && showUpgradeBanner)
                  _buildUpgradeBanner(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Manage Staff Members",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "This section displays all the staff members associated with your practice. You can invite new team members, assign them clinical or non-clinical roles, and track their status and linked profiles. Your plan determines the number of staff members you can add.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildAnalyticsCard(
                            "Allowed Staff", "$allowedStaffCount"),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAnalyticsCard(
                            "Staff Added", "${staffList.length}"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: staffList.isEmpty
                      ? const Center(child: Text("No staff invited yet."))
                      : ListView.builder(
                          itemCount: staffList.length,
                          itemBuilder: (context, index) {
                            final staff = staffList[index];
                            final status = staff['status'];
                            final role = staff['role'] ?? 'Unassigned';
                            final email = staff['email'];
                            final staffType = staff['staff_type'];
                            final id = staff['id'];

                            final addedByOwner = staff['added_by_owner'];
                            final addedBy = staff['added_by'];
                            final userInfo = staff['user_info'];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: userInfo != null
                                              ? Colors.teal.shade100
                                              : Colors.grey[300],
                                          child: Icon(
                                            userInfo != null
                                                ? Icons.person
                                                : Icons.person_off,
                                            color: userInfo != null
                                                ? Colors.teal
                                                : Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                userInfo != null
                                                    ? userInfo['name']
                                                    : "No Profile Linked",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: userInfo != null
                                                      ? Colors.teal[800]
                                                      : Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                email,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: status == "Accepted"
                                                ? Colors.green.shade100
                                                : Colors.orange.shade100,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                status == "Accepted"
                                                    ? Icons.check_circle
                                                    : Icons.hourglass_bottom,
                                                size: 14,
                                                color: status == "Accepted"
                                                    ? Colors.green.shade800
                                                    : Colors.orange.shade800,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                status,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: status == "Accepted"
                                                      ? Colors.green.shade800
                                                      : Colors.orange.shade800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20),
                                    _infoRow("Staff ID", id),
                                    _infoRow("$staffType Role", "$role"),
                                    if (addedByOwner != null)
                                      _infoRow(
                                          "Added by", addedByOwner['name']),
                                    if (addedBy != null)
                                      _infoRow("Added by", addedBy['name']),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (staffList.length >= allowedStaffCount) {
            setState(() {
              showUpgradeBanner = true;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text("Staff limit reached. Upgrade your plan to add more."),
                backgroundColor: Colors.redAccent,
              ),
            );
          } else {
            _navigateToInviteScreen();
          }
        },
        backgroundColor:
            staffList.length >= allowedStaffCount ? Colors.grey : Colors.teal,
        tooltip: "Invite New Staff",
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String label, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeBanner() {
    return Container(
      color: Colors.red.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Staff Limit Reached",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "You’ve reached the maximum number of allowed staff members. Please upgrade your plan to add more team members.",
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewEditPracticeScreen(
                          ownerId: "",
                          practiceId: widget.practiceId,
                          initialTabIndex: 1,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.upgrade),
                  label: const Text("Upgrade Plan"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                showUpgradeBanner = false;
              });
            },
            icon: const Icon(Icons.close, color: Colors.redAccent),
            tooltip: "Dismiss",
          ),
        ],
      ),
    );
  }
}
