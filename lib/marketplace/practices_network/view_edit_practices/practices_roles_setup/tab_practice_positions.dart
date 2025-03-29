import 'dart:convert';
import 'package:dental_key/marketplace/practices_network/view_edit_practices/practices_roles_setup/roles_form_screen.dart';
import 'package:dental_key/marketplace/practices_network/view_edit_practices/view_edit_practices.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dental_key/marketplace/practices_network/view_edit_practices/practices_roles_setup/practice_role.dart';

class PracticeRolesScreen extends StatefulWidget {
  final String practiceId;

  const PracticeRolesScreen({Key? key, required this.practiceId})
      : super(key: key);

  @override
  State<PracticeRolesScreen> createState() => _PracticeRolesScreenState();
}

class _PracticeRolesScreenState extends State<PracticeRolesScreen> {
  List<PracticeRole> roles = [];
  bool isLoading = true;
  int allowedRoles = 0;
  bool showUpgradeBanner = true;

  final List<Color> roleCardColors = [
    Colors.lightBlue.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.red.shade100,
    Colors.teal.shade100,
    Colors.amber.shade100,
    Colors.pink.shade100,
    Colors.indigo.shade100,
    Colors.lime.shade100,
    Colors.cyan.shade100,
    Colors.deepOrange.shade100,
    Colors.lightGreen.shade100,
    Colors.deepPurple.shade100,
    Colors.brown.shade100,
  ];

  @override
  void initState() {
    super.initState();
    fetchAllowedRoles();
    fetchRoles();
  }

  Future<void> fetchRoles() async {
    final prefs = await SharedPreferences.getInstance();
    final ownerEmail = prefs.getString('owner_email') ?? '';

    final response = await http.get(
      Uri.parse(
          "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/practice-role/?practice=${widget.practiceId}"),
      headers: {
        'Content-Type': 'application/json',
        'X-User-Email': ownerEmail,
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      setState(() {
        roles = data.map((json) => PracticeRole.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load roles')),
      );
    }
  }

  Future<void> fetchAllowedRoles() async {
    final response = await http.get(
      Uri.parse(
          "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/packages/${widget.practiceId}/"),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final package = json.decode(response.body);
      setState(() {
        allowedRoles = package['max_roles'] ?? 0;
      });
    } else {
      print("⚠️ Failed to fetch package info");
    }
  }

  void deleteRole(String roleId) async {
    final prefs = await SharedPreferences.getInstance();
    final ownerEmail = prefs.getString('owner_email') ?? '';

    final res = await http.delete(
      Uri.parse(
          "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/practice-role/$roleId/"),
      headers: {
        'Content-Type': 'application/json',
        'X-User-Email': ownerEmail,
      },
    );

    if (res.statusCode == 204) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Role deleted")));
      fetchRoles();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Delete failed")));
    }
  }

  void openRoleEditor({PracticeRole? role}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoleFormScreen(
          practiceId: widget.practiceId,
          existingRole: role,
        ),
      ),
    );
    fetchRoles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (roles.length >= allowedRoles && showUpgradeBanner)
                  Container(
                    color: Colors.red.shade50,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.redAccent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Role Limit Reached",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "You’ve reached the maximum number of allowed roles. Please upgrade your plan to add more positions.",
                                style: TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ViewEditPracticeScreen(
                                        ownerId:
                                            "", // ✅ Replace with actual ownerId if you have it
                                        practiceId: widget.practiceId,
                                        initialTabIndex:
                                            1, // 📌 1 means "Package" tab (2nd tab, index starts from 0)
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
                              showUpgradeBanner = false; // just hide the banner
                            });
                          },
                          icon:
                              const Icon(Icons.close, color: Colors.redAccent),
                          tooltip: "Dismiss",
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      Text(
                        "Manage Roles Your Practice Has",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "You can manage all staff roles for your practice here. Assign permissions to define what each staff member can access and perform in the system.",
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 20),

                      // 🔷 Analytics
                      Row(
                        children: [
                          Expanded(
                            child: _buildAnalyticsCard(
                                "Allowed Roles", allowedRoles.toString()),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildAnalyticsCard(
                                "Roles Added", roles.length.toString()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      roles.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 80),
                              child: Center(
                                child: Text(
                                  "You have not added any positions your practice has.",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : Column(
                              children: List.generate(roles.length, (index) {
                                final role = roles[index];
                                final color = roleCardColors[
                                    index % roleCardColors.length];
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 3,
                                  color: color,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(role.title,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(height: 6),
                                            Text(
                                                "Permissions: ${role.permissions.length}"),
                                          ],
                                        ),
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              openRoleEditor(role: role);
                                            }
                                            if (value == 'delete') {
                                              deleteRole(role.id);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                                value: 'edit',
                                                child: Text('Edit')),
                                            const PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Delete')),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (roles.length >= allowedRoles) {
            setState(() {
              showUpgradeBanner = true; // force banner to reappear
            });
            // Optional: show toast/snackbar too
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "You’ve reached your role limit. Upgrade your plan to add more.",
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
          } else {
            openRoleEditor();
          }
        },
        child: const Icon(Icons.add),
        tooltip: "Add New Role",
        backgroundColor:
            roles.length >= allowedRoles ? Colors.grey : Colors.teal,
      ),
    );
  }

  Widget _buildAnalyticsCard(String label, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
